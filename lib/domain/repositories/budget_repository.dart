import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/domain/entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, Budget>> getCurrentBudget();
  Future<Either<Failure, Budget>> updateBudget(Budget budget);
  Future<Either<Failure, Budget>> adjustSpending(double delta);
  Stream<Budget> watchBudget();
}
