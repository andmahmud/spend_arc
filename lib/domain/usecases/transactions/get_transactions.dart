import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/domain/repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;

  GetTransactions({required this.repository});

  Future<Either<Failure, List<Transaction>>> call() {
    return repository.getTransactions();
  }
}

class GetTransactionsByMonth {
  final TransactionRepository repository;

  GetTransactionsByMonth({required this.repository});

  Future<Either<Failure, List<Transaction>>> call(int month, int year) {
    return repository.getTransactionsByMonth(month, year);
  }
}
