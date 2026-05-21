import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:spend_arc/core/theme/app_theme.dart';

enum TransactionCategoryType { income, expense }

class TransactionCategory extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionCategoryType type;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type];

  static List<TransactionCategory> get defaults => [
    TransactionCategory(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: AppColors.categoryColors[0],
      type: TransactionCategoryType.expense,
    ),
    TransactionCategory(
      id: 'transport',
      name: 'Transportation',
      icon: Icons.directions_car_rounded,
      color: AppColors.categoryColors[1],
      type: TransactionCategoryType.expense,
    ),
    TransactionCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.categoryColors[2],
      type: TransactionCategoryType.expense,
    ),
    TransactionCategory(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_rounded,
      color: AppColors.categoryColors[3],
      type: TransactionCategoryType.expense,
    ),
    TransactionCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: AppColors.categoryColors[4],
      type: TransactionCategoryType.expense,
    ),
    TransactionCategory(
      id: 'health',
      name: 'Health & Fitness',
      icon: Icons.favorite_rounded,
      color: AppColors.categoryColors[5],
      type: TransactionCategoryType.expense,
    ),
    TransactionCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: AppColors.categoryColors[6],
      type: TransactionCategoryType.expense,
    ),
    TransactionCategory(
      id: 'salary',
      name: 'Salary',
      icon: Icons.work_rounded,
      color: AppColors.categoryColors[7],
      type: TransactionCategoryType.income,
    ),
    TransactionCategory(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.code_rounded,
      color: AppColors.categoryColors[8],
      type: TransactionCategoryType.income,
    ),
    TransactionCategory(
      id: 'investment',
      name: 'Investment',
      icon: Icons.trending_up_rounded,
      color: AppColors.categoryColors[9],
      type: TransactionCategoryType.income,
    ),
  ];
}
