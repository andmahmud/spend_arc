import 'package:equatable/equatable.dart';
import 'package:spend_arc/domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransactionEvent({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  const DeleteTransactionEvent({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class SyncTransactionsEvent extends TransactionEvent {}

class TransactionModified extends TransactionEvent {
  final Transaction transaction;

  const TransactionModified({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionEvent {
  final String transactionId;

  const TransactionDeleted({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}
