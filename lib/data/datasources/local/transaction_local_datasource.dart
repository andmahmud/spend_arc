import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spend_arc/core/constants/app_constants.dart';
import 'package:spend_arc/core/errors/exceptions.dart';
import 'package:spend_arc/data/models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel?> getTransactionById(String id);
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionModel>> getTransactionsByMonth(int month, int year);
  Future<void> markAsSynced(String id);
  Stream<List<TransactionModel>> watchTransactions();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  late final Box _box;
  bool _boxInitialized = false;
  final StreamController<List<TransactionModel>> _controller =
      StreamController<List<TransactionModel>>.broadcast();

  Future<void> _ensureBox() async {
    if (!_boxInitialized) {
      _box = await Hive.openBox(AppConstants.hiveBoxName);
      _boxInitialized = true;
    }
  }

  List<TransactionModel> _getAllFromBox() {
    final data = _box.get(AppConstants.transactionsKey);
    if (data == null) return [];
    final list = data as List;
    return list
        .map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveAll(List<TransactionModel> transactions) async {
    await _box.put(
      AppConstants.transactionsKey,
      transactions.map((t) => t.toMap()).toList(),
    );
    _controller.add(transactions);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      await _ensureBox();
      return _getAllFromBox();
    } catch (e) {
      throw CacheException(message: 'Failed to get transactions: $e');
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      await _ensureBox();
      final transactions = _getAllFromBox();
      final index = transactions.indexWhere((t) => t.id == id);
      return index >= 0 ? transactions[index] : null;
    } catch (e) {
      throw CacheException(message: 'Failed to get transaction: $e');
    }
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      await _ensureBox();
      final transactions = _getAllFromBox();
      transactions.add(transaction);
      await _saveAll(transactions);
      return transaction;
    } catch (e) {
      throw CacheException(message: 'Failed to add transaction: $e');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      await _ensureBox();
      final transactions = _getAllFromBox();
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      if (index < 0) {
        throw CacheException(message: 'Transaction not found');
      }
      transactions[index] = transaction;
      await _saveAll(transactions);
      return transaction;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _ensureBox();
      final transactions = _getAllFromBox();
      transactions.removeWhere((t) => t.id == id);
      await _saveAll(transactions);
    } catch (e) {
      throw CacheException(message: 'Failed to delete transaction: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByMonth(int month, int year) async {
    try {
      await _ensureBox();
      final transactions = _getAllFromBox();
      return transactions
          .where((t) => t.date.month == month && t.date.year == year)
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get transactions by month: $e');
    }
  }

  @override
  Future<void> markAsSynced(String id) async {
    try {
      await _ensureBox();
      final transactions = _getAllFromBox();
      final index = transactions.indexWhere((t) => t.id == id);
      if (index >= 0) {
        final updated = TransactionModel.fromMap({
          ...transactions[index].toMap(),
          'isSynced': true,
        });
        transactions[index] = updated;
        await _saveAll(transactions);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to mark as synced: $e');
    }
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
