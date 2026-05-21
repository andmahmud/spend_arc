import 'package:equatable/equatable.dart';
import 'package:spend_arc/domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  const TransactionLoaded({required this.transactions});

  TransactionLoaded copyWith({List<Transaction>? transactions}) {
    return TransactionLoaded(transactions: transactions ?? this.transactions);
  }

  @override
  List<Object?> get props => [transactions];
}

class TransactionOperationInProgress extends TransactionState {
  final List<Transaction> transactions;

  const TransactionOperationInProgress({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class TransactionSuccess extends TransactionState {
  final String message;

  const TransactionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}
