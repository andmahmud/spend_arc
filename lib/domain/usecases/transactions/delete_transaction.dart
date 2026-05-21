import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/domain/repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repository;

  DeleteTransaction({required this.repository});

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTransaction(id);
  }
}
