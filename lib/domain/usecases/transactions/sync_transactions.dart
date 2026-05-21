import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/domain/repositories/transaction_repository.dart';

class SyncTransactions {
  final TransactionRepository repository;

  SyncTransactions({required this.repository});

  Future<Either<Failure, void>> call() {
    return repository.syncTransactions();
  }
}
