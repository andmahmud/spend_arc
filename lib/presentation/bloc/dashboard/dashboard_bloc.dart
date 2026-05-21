import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/domain/usecases/budgets/get_budget.dart';
import 'package:spend_arc/domain/usecases/transactions/get_transactions.dart';
import 'package:spend_arc/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:spend_arc/presentation/bloc/dashboard/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetTransactions getTransactions;
  final GetCurrentBudget getCurrentBudget;
  final GetTransactionsByMonth getTransactionsByMonth;

  StreamSubscription? _transactionSubscription;

  DashboardBloc({
    required this.getTransactions,
    required this.getCurrentBudget,
    required this.getTransactionsByMonth,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final now = DateTime.now();
    final results = await Future.wait([
      getTransactions(),
      getCurrentBudget(),
      getTransactionsByMonth(now.month, now.year),
    ]);

    final txResult = results[0] as dynamic;
    final budgetResult = results[1] as dynamic;
    final monthlyResult = results[2] as dynamic;

    String errorMessage = '';

    final transactions = txResult.fold(
      (failure) {
        errorMessage = failure.message;
        return <Transaction>[];
      },
      (list) => list as List<Transaction>,
    );

    final budget = budgetResult.fold(
      (failure) {
        errorMessage = errorMessage.isEmpty ? failure.message : errorMessage;
        return null;
      },
      (b) => b,
    );

    final monthlyTransactions = monthlyResult.fold(
      (failure) {
        errorMessage = errorMessage.isEmpty ? failure.message : errorMessage;
        return <Transaction>[];
      },
      (list) => list as List<Transaction>,
    );

    if (budget == null && errorMessage.isNotEmpty) {
      emit(DashboardError(message: errorMessage));
      return;
    }

    final recentTransactions = transactions.take(5).toList();

    final totalIncome = monthlyTransactions
        .where((Transaction t) => t.type == TransactionType.income)
        .fold<double>(0.0, (double sum, Transaction t) => sum + t.amount);

    final totalExpense = monthlyTransactions
        .where((Transaction t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (double sum, Transaction t) => sum + t.amount);

    emit(DashboardLoaded(
      data: DashboardData(
        recentTransactions: recentTransactions,
        budget: budget!,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        monthlyTransactions: monthlyTransactions,
      ),
    ));
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadDashboard());
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}
