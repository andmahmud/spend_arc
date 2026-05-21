import 'dart:math';
import 'package:spend_arc/core/errors/exceptions.dart';
import 'package:spend_arc/data/models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> fetchTransactions();
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> syncTransactions(List<TransactionModel> localTransactions);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  int _requestCount = 0;
  final Random _random = Random();

  double get _latencyMs => 200 + _random.nextDouble() * 300;

  Future<void> _simulateNetwork() async {
    _requestCount++;
    await Future.delayed(Duration(milliseconds: _latencyMs.round()));

    if (_requestCount % 10 == 0) {
      throw ServerException(
        message: 'Simulated server error',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    await _simulateNetwork();
    return [];
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    await _simulateNetwork();
    return TransactionModel.fromMap({
      ...transaction.toMap(),
      'isSynced': true,
    });
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    await _simulateNetwork();
    return TransactionModel.fromMap({
      ...transaction.toMap(),
      'isSynced': true,
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _simulateNetwork();
  }

  @override
  Future<void> syncTransactions(List<TransactionModel> localTransactions) async {
    await _simulateNetwork();
    final unsynced = localTransactions.where((t) => !t.isSynced).toList();
    for (final _ in unsynced) {
      await _simulateNetwork();
    }
  }
}
