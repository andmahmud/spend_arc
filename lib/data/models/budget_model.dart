import 'package:spend_arc/domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.totalAmount,
    required super.spentAmount,
    required super.month,
    required super.year,
    required super.updatedAt,
  });

  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      id: entity.id,
      totalAmount: entity.totalAmount,
      spentAmount: entity.spentAmount,
      month: entity.month,
      year: entity.year,
      updatedAt: entity.updatedAt,
    );
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      spentAmount: (map['spentAmount'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'spentAmount': spentAmount,
      'month': month,
      'year': year,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Budget toEntity() {
    return Budget(
      id: id,
      totalAmount: totalAmount,
      spentAmount: spentAmount,
      month: month,
      year: year,
      updatedAt: updatedAt,
    );
  }
}
