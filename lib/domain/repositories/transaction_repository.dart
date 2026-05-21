import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();
  Future<Either<Failure, Transaction>> getTransactionById(String id);
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, List<Transaction>>> getTransactionsByMonth(int month, int year);
  Future<Either<Failure, void>> syncTransactions();
  Stream<List<Transaction>> watchTransactions();
}
