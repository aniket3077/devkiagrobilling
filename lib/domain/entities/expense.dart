import 'package:equatable/equatable.dart';

enum ExpenseFrequency { once, daily, weekly, monthly, yearly }

class Expense extends Equatable {
  final String id;
  final String tenantId;
  final String categoryId;
  final String categoryName;
  final double amount;
  final String description;
  final DateTime date;
  final String paymentMethod;
  final bool isRecurring;
  final ExpenseFrequency frequency;

  const Expense({
    required this.id,
    required this.tenantId,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.description,
    required this.date,
    required this.paymentMethod,
    this.isRecurring = false,
    this.frequency = ExpenseFrequency.once,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        categoryId,
        categoryName,
        amount,
        description,
        date,
        paymentMethod,
        isRecurring,
        frequency,
      ];
}

class ExpenseCategory extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final String? icon;

  const ExpenseCategory({
    required this.id,
    required this.tenantId,
    required this.name,
    this.icon,
  });

  @override
  List<Object?> get props => [id, tenantId, name, icon];
}
