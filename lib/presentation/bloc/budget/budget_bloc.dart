import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_arc/domain/usecases/budgets/get_budget.dart';
import 'package:spend_arc/domain/usecases/budgets/update_budget.dart';
import 'package:spend_arc/presentation/bloc/budget/budget_event.dart';
import 'package:spend_arc/presentation/bloc/budget/budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetCurrentBudget getCurrentBudget;
  final AdjustSpending adjustSpending;
  final UpdateBudget updateBudget;

  BudgetBloc({
    required this.getCurrentBudget,
    required this.adjustSpending,
    required this.updateBudget,
  }) : super(BudgetInitial()) {
    on<LoadBudget>(_onLoadBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<AdjustSpendingEvent>(_onAdjustSpending);
  }

  Future<void> _onLoadBudget(
    LoadBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    final result = await getCurrentBudget();
    result.fold(
      (failure) => emit(BudgetError(message: failure.message)),
      (budget) => emit(BudgetLoaded(budget: budget)),
    );
  }

  Future<void> _onUpdateBudget(
    UpdateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    if (state is BudgetLoaded) {
      final result = await updateBudget(event.budget);
      result.fold(
        (failure) => emit(BudgetError(message: failure.message)),
        (budget) => emit(BudgetLoaded(budget: budget)),
      );
    }
  }

  Future<void> _onAdjustSpending(
    AdjustSpendingEvent event,
    Emitter<BudgetState> emit,
  ) async {
    if (state is BudgetLoaded) {
      final current = state as BudgetLoaded;

      final optimistic = current.budget.copyWith(
        spentAmount: (current.budget.spentAmount + event.delta)
            .clamp(0, double.infinity),
      );

      emit(BudgetLoaded(budget: optimistic));

      final result = await adjustSpending(event.delta);
      result.fold(
        (failure) {
          emit(BudgetLoaded(budget: current.budget));
        },
        (budget) {
          emit(BudgetLoaded(budget: budget));
        },
      );
    } else {
      final result = await adjustSpending(event.delta);
      result.fold(
        (failure) => emit(BudgetError(message: failure.message)),
        (budget) => emit(BudgetLoaded(budget: budget)),
      );
    }
  }
}
