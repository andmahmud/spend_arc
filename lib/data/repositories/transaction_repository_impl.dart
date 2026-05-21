import 'dart:async';
import 'package:spend_arc/core/errors/exceptions.dart';
import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/network/network_info.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/data/datasources/local/transaction_local_datasource.dart';
import 'package:spend_arc/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:spend_arc/data/models/transaction_model.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/domain/repositories/budget_repository.dart';
import 'package:spend_arc/domain/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final BudgetRepository budgetRepository;
  final Uuid _uuid = const Uuid();

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.budgetRepository,
  });

  @override
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction) async {
    try {
      final tx = transaction.id.isEmpty
          ? transaction.copyWith(id: _uuid.v4())
          : transaction;
      final model = TransactionModel.fromEntity(tx);
      final saved = await localDataSource.addTransaction(model);
      unawaited(_trySyncSingle(saved));
      _adjustBudgetForTransaction(tx);
      return right(saved.toEntity());
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  void _adjustBudgetForTransaction(Transaction transaction) {
    if (transaction.type == TransactionType.expense) {
      unawaited(budgetRepository.adjustSpending(transaction.amount));
    }
  }

  Future<void> _trySyncSingle(TransactionModel transaction) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.createTransaction(transaction);
        await localDataSource.markAsSynced(transaction.id);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      final tx = await localDataSource.getTransactionById(id);
      await localDataSource.deleteTransaction(id);
      unawaited(_tryRemoteDelete(id));
      if (tx != null && tx.type == TransactionType.expense) {
        unawaited(budgetRepository.adjustSpending(-tx.amount));
      }
      return right(null);
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  Future<void> _tryRemoteDelete(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.deleteTransaction(id);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      final result = await localDataSource.getTransactionById(id);
      if (result == null) {
        return left(CacheFailure(message: 'Transaction not found'));
      }
      return right(result.toEntity());
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final transactions = await localDataSource.getTransactions();
      return right(transactions.map((t) => t.toEntity()).toList());
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByMonth(
      int month, int year) async {
    try {
      final transactions =
          await localDataSource.getTransactionsByMonth(month, year);
      return right(transactions.map((t) => t.toEntity()).toList());
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction) async {
    try {
      final old = await localDataSource.getTransactionById(transaction.id);
      final model = TransactionModel.fromEntity(transaction);
      final updated = await localDataSource.updateTransaction(model);
      unawaited(_trySyncSingle(updated));

      if (old != null) {
        if (old.type == TransactionType.expense) {
          unawaited(budgetRepository.adjustSpending(-old.amount));
        }
        if (transaction.type == TransactionType.expense) {
          unawaited(budgetRepository.adjustSpending(transaction.amount));
        }
      }

      return right(updated.toEntity());
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncTransactions() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return left(NetworkFailure());
      }

      final local = await localDataSource.getTransactions();
      final unsynced = local.where((t) => !t.isSynced).toList();

      for (final transaction in unsynced) {
        try {
          await remoteDataSource.createTransaction(transaction);
          await localDataSource.markAsSynced(transaction.id);
        } on ServerException catch (e) {
          return left(ServerFailure(message: e.message));
        }
      }
      return right(null);
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Transaction>> watchTransactions() {
    return localDataSource
        .watchTransactions()
        .map((list) => list.map((t) => t.toEntity()).toList());
  }
}
