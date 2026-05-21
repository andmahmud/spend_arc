import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/domain/repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;

  AddTransaction({required this.repository});

  Future<Either<Failure, Transaction>> call(Transaction transaction) {
    return repository.addTransaction(transaction);
  }
}
