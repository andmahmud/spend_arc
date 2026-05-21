import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/domain/entities/budget.dart';
import 'package:spend_arc/domain/repositories/budget_repository.dart';

class UpdateBudget {
  final BudgetRepository repository;

  UpdateBudget({required this.repository});

  Future<Either<Failure, Budget>> call(Budget budget) {
    return repository.updateBudget(budget);
  }
}

class AdjustSpending {
  final BudgetRepository repository;

  AdjustSpending({required this.repository});

  Future<Either<Failure, Budget>> call(double delta) {
    return repository.adjustSpending(delta);
  }
}
