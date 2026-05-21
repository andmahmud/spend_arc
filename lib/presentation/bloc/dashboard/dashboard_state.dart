import 'package:equatable/equatable.dart';
import 'package:spend_arc/domain/entities/budget.dart';
import 'package:spend_arc/domain/entities/transaction.dart';

class DashboardData extends Equatable {
  final List<Transaction> recentTransactions;
  final Budget budget;
  final double totalIncome;
  final double totalExpense;
  final List<Transaction> monthlyTransactions;

  const DashboardData({
    required this.recentTransactions,
    required this.budget,
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyTransactions,
  });

  double get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props =>
      [recentTransactions, budget, totalIncome, totalExpense, monthlyTransactions];
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData data;

  const DashboardLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
