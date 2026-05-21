import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spend_arc/core/constants/app_constants.dart';
import 'package:spend_arc/core/errors/exceptions.dart';
import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/data/models/budget_model.dart';
import 'package:spend_arc/domain/entities/budget.dart';
import 'package:spend_arc/domain/repositories/budget_repository.dart';
import 'package:uuid/uuid.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  late final Box _box;
  bool _boxInitialized = false;
  final StreamController<Budget> _controller =
      StreamController<Budget>.broadcast();
  final Uuid _uuid = const Uuid();

  Future<void> _ensureBox() async {
    if (!_boxInitialized) {
      _box = await Hive.openBox(AppConstants.hiveBoxName);
      _boxInitialized = true;
    }
  }

  String _budgetKey(int month, int year) => 'budget_${month}_$year';

  Future<BudgetModel?> _getFromBox() async {
    await _ensureBox();
    final now = DateTime.now();
    final key = _budgetKey(now.month, now.year);
    final data = _box.get(key);
    if (data == null) return null;
    return BudgetModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<BudgetModel> _getOrCreateDefault() async {
    final now = DateTime.now();
    final existing = await _getFromBox();
    if (existing != null) return existing;

    final budget = BudgetModel(
      id: _uuid.v4(),
      totalAmount: AppConstants.defaultMonthlyBudget,
      spentAmount: 0,
      month: now.month,
      year: now.year,
      updatedAt: now,
    );
    await _saveToBox(budget);
    return budget;
  }

  Future<void> _saveToBox(BudgetModel budget) async {
    await _ensureBox();
    final key = _budgetKey(budget.month, budget.year);
    await _box.put(key, budget.toMap());
    _controller.add(budget.toEntity());
  }

  @override
  Future<Either<Failure, Budget>> getCurrentBudget() async {
    try {
      final budget = await _getOrCreateDefault();
      return right(budget.toEntity());
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudget(Budget budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      await _saveToBox(model);
      return right(model.toEntity());
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> adjustSpending(double delta) async {
    try {
      final budget = await _getOrCreateDefault();
      final updated = BudgetModel(
        id: budget.id,
        totalAmount: budget.totalAmount,
        spentAmount: (budget.spentAmount + delta).clamp(0, double.infinity),
        month: budget.month,
        year: budget.year,
        updatedAt: DateTime.now(),
      );
      await _saveToBox(updated);
      return right(updated.toEntity());
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<Budget> watchBudget() {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
