import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_arc/core/network/network_info.dart';
import 'package:spend_arc/domain/usecases/transactions/sync_transactions.dart';
import 'package:spend_arc/presentation/bloc/sync/sync_event.dart';
import 'package:spend_arc/presentation/bloc/sync/sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncTransactions syncTransactions;
  final NetworkInfo networkInfo;
  StreamSubscription? _networkSubscription;
  Timer? _periodicTimer;
  DateTime? _lastSyncTime;

  SyncBloc({
    required this.syncTransactions,
    required this.networkInfo,
  }) : super(SyncInitial()) {
    on<StartSync>(_onStartSync);
    on<TriggerSync>(_onTriggerSync);
    on<TransactionAddedForSync>(_onTransactionChanged);
    on<TransactionUpdatedForSync>(_onTransactionChanged);
    on<TransactionDeletedForSync>(_onTransactionDeleted);
    on<NetworkStatusChanged>(_onNetworkStatusChanged);

    _initNetworkListener();
  }

  void _initNetworkListener() {
    _networkSubscription = networkInfo.onConnectivityChanged.listen((isConnected) {
      add(NetworkStatusChanged(isConnected: isConnected));
      if (isConnected) {
        add(TriggerSync());
      }
    });

    networkInfo.isConnected.then((connected) {
      add(NetworkStatusChanged(isConnected: connected));
    });

    _periodicTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => add(TriggerSync()),
    );
  }

  Future<void> _onStartSync(
    StartSync event,
    Emitter<SyncState> emit,
  ) async {
    final isConnected = await networkInfo.isConnected;
    emit(SyncIdle(isOnline: isConnected, lastSyncTime: _lastSyncTime));
  }

  Future<void> _onTriggerSync(
    TriggerSync event,
    Emitter<SyncState> emit,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      emit(SyncIdle(isOnline: false, lastSyncTime: _lastSyncTime));
      return;
    }

    emit(SyncInProgress());

    final result = await syncTransactions();
    result.fold(
      (failure) => emit(SyncFailure(message: failure.message)),
      (_) {
        _lastSyncTime = DateTime.now();
        emit(SyncSuccess(syncedCount: 1));
        emit(SyncIdle(isOnline: true, lastSyncTime: _lastSyncTime));
      },
    );
  }

  Future<void> _onTransactionChanged(
    SyncEvent event,
    Emitter<SyncState> emit,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      add(TriggerSync());
    }
  }

  Future<void> _onTransactionDeleted(
    TransactionDeletedForSync event,
    Emitter<SyncState> emit,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      add(TriggerSync());
    }
  }

  Future<void> _onNetworkStatusChanged(
    NetworkStatusChanged event,
    Emitter<SyncState> emit,
  ) async {
    if (state is SyncIdle || state is SyncFailure || state is SyncSuccess) {
      emit(SyncIdle(isOnline: event.isConnected, lastSyncTime: _lastSyncTime));
    }
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _periodicTimer?.cancel();
    return super.close();
  }
}
