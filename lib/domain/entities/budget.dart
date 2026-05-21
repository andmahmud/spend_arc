import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final double totalAmount;
  final double spentAmount;
  final int month;
  final int year;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.totalAmount,
    required this.spentAmount,
    required this.month,
    required this.year,
    required this.updatedAt,
  });

  double get remainingAmount => totalAmount - spentAmount;
  double get usagePercentage => totalAmount > 0 ? (spentAmount / totalAmount).clamp(0.0, 1.0) : 0.0;

  Budget copyWith({
    String? id,
    double? totalAmount,
    double? spentAmount,
    int? month,
    int? year,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      totalAmount: totalAmount ?? this.totalAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, totalAmount, spentAmount, month, year, updatedAt];
}
