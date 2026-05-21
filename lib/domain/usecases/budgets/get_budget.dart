import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/domain/entities/budget.dart';
import 'package:spend_arc/domain/repositories/budget_repository.dart';

class GetCurrentBudget {
  final BudgetRepository repository;

  GetCurrentBudget({required this.repository});

  Future<Either<Failure, Budget>> call() {
    return repository.getCurrentBudget();
  }
}
