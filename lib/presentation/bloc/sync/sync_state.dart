import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}

class SyncIdle extends SyncState {
  final DateTime? lastSyncTime;
  final bool isOnline;

  const SyncIdle({this.lastSyncTime, this.isOnline = true});

  @override
  List<Object?> get props => [lastSyncTime, isOnline];
}

class SyncInProgress extends SyncState {
  final int pendingCount;

  const SyncInProgress({this.pendingCount = 0});

  @override
  List<Object?> get props => [pendingCount];
}

class SyncSuccess extends SyncState {
  final int syncedCount;

  const SyncSuccess({this.syncedCount = 0});

  @override
  List<Object?> get props => [syncedCount];
}

class SyncFailure extends SyncState {
  final String message;

  const SyncFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
