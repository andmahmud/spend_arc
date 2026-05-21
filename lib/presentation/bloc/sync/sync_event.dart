import 'package:equatable/equatable.dart';
import 'package:spend_arc/domain/entities/transaction.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class StartSync extends SyncEvent {}

class TransactionAddedForSync extends SyncEvent {
  final Transaction transaction;

  const TransactionAddedForSync({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdatedForSync extends SyncEvent {
  final Transaction transaction;

  const TransactionUpdatedForSync({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeletedForSync extends SyncEvent {
  final String transactionId;

  const TransactionDeletedForSync({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class NetworkStatusChanged extends SyncEvent {
  final bool isConnected;

  const NetworkStatusChanged({required this.isConnected});

  @override
  List<Object?> get props => [isConnected];
}

class TriggerSync extends SyncEvent {}
