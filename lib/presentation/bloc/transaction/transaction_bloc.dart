import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_arc/domain/usecases/transactions/add_transaction.dart';
import 'package:spend_arc/domain/usecases/transactions/delete_transaction.dart';
import 'package:spend_arc/domain/usecases/transactions/get_transactions.dart';
import 'package:spend_arc/domain/usecases/transactions/sync_transactions.dart';
import 'package:spend_arc/domain/usecases/transactions/update_transaction.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_event.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final GetTransactions getTransactions;
  final SyncTransactions syncTransactions;

  StreamSubscription? _watchSubscription;

  TransactionBloc({
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.getTransactions,
    required this.syncTransactions,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<SyncTransactionsEvent>(_onSyncTransactions);
    on<TransactionModified>(_onTransactionModified);
    on<TransactionDeleted>(_onTransactionDeletedEvent);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTransactions();
    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (transactions) => emit(TransactionLoaded(transactions: transactions)),
    );
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      final optimisticList = [event.transaction, ...currentState.transactions];

      emit(TransactionOperationInProgress(transactions: optimisticList));

      final result = await addTransaction(event.transaction);
      result.fold(
        (failure) {
          emit(TransactionLoaded(transactions: currentState.transactions));
          emit(TransactionError(message: failure.message));
        },
        (tx) {
          final updatedList =
              optimisticList.map((t) => t.id == tx.id ? tx : t).toList();
          emit(TransactionLoaded(transactions: updatedList));
          emit(TransactionSuccess(message: 'Transaction added'));
        },
      );
    } else {
      emit(TransactionLoading());
      final result = await addTransaction(event.transaction);
      result.fold(
        (failure) => emit(TransactionError(message: failure.message)),
        (tx) {
          emit(TransactionLoaded(transactions: [tx]));
          emit(TransactionSuccess(message: 'Transaction added'));
        },
      );
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      final optimisticList = currentState.transactions.map((t) {
        return t.id == event.transaction.id ? event.transaction : t;
      }).toList();

      emit(TransactionOperationInProgress(transactions: optimisticList));

      final result = await updateTransaction(event.transaction);
      result.fold(
        (failure) {
          emit(TransactionLoaded(transactions: currentState.transactions));
          emit(TransactionError(message: failure.message));
        },
        (tx) {
          final updatedList = optimisticList
              .map((t) => t.id == tx.id ? tx : t)
              .toList();
          emit(TransactionLoaded(transactions: updatedList));
          emit(TransactionSuccess(message: 'Transaction updated'));
        },
      );
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      final optimisticList = currentState.transactions
          .where((t) => t.id != event.transactionId)
          .toList();

      emit(TransactionOperationInProgress(transactions: optimisticList));

      final result = await deleteTransaction(event.transactionId);
      result.fold(
        (failure) {
          emit(TransactionLoaded(transactions: currentState.transactions));
          emit(TransactionError(message: failure.message));
        },
        (_) {
          emit(TransactionLoaded(transactions: optimisticList));
          emit(TransactionSuccess(message: 'Transaction deleted'));
          add(LoadTransactions());
        },
      );
    }
  }

  Future<void> _onSyncTransactions(
    SyncTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionOperationInProgress(
      transactions: state is TransactionLoaded
          ? (state as TransactionLoaded).transactions
          : [],
    ));

    final result = await syncTransactions();
    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (_) {
        add(LoadTransactions());
        emit(TransactionSuccess(message: 'Sync completed'));
      },
    );
  }

  void _onTransactionModified(
    TransactionModified event,
    Emitter<TransactionState> emit,
  ) {
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      final updated = current.transactions.map((t) {
        return t.id == event.transaction.id ? event.transaction : t;
      }).toList();
      emit(TransactionLoaded(transactions: updated));
    }
  }

  void _onTransactionDeletedEvent(
    TransactionDeleted event,
    Emitter<TransactionState> emit,
  ) {
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      final updated =
          current.transactions.where((t) => t.id != event.transactionId).toList();
      emit(TransactionLoaded(transactions: updated));
    }
  }

  @override
  Future<void> close() {
    _watchSubscription?.cancel();
    return super.close();
  }
}
