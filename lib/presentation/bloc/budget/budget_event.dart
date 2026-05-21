import 'package:equatable/equatable.dart';
import 'package:spend_arc/domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudget extends BudgetEvent {}

class UpdateBudgetEvent extends BudgetEvent {
  final Budget budget;

  const UpdateBudgetEvent({required this.budget});

  @override
  List<Object?> get props => [budget];
}

class AdjustSpendingEvent extends BudgetEvent {
  final double delta;

  const AdjustSpendingEvent({required this.delta});

  @override
  List<Object?> get props => [delta];
}

class BudgetSpendingAdjusted extends BudgetEvent {
  final double delta;

  const BudgetSpendingAdjusted({required this.delta});

  @override
  List<Object?> get props => [delta];
}
