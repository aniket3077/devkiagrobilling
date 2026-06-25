import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.tenantId,
    required super.categoryId,
    required super.categoryName,
    required super.amount,
    required super.description,
    required super.date,
    required super.paymentMethod,
    super.isRecurring,
    super.frequency,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      tenantId: map['tenantId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      paymentMethod: map['paymentMethod'] ?? '',
      isRecurring: map['isRecurring'] ?? false,
      frequency: ExpenseFrequency.values.firstWhere(
        (e) => e.name == (map['frequency'] ?? 'once'),
        orElse: () => ExpenseFrequency.once,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'paymentMethod': paymentMethod,
      'isRecurring': isRecurring,
      'frequency': frequency.name,
    };
  }
}

class ExpenseCategoryModel extends ExpenseCategory {
  const ExpenseCategoryModel({
    required super.id,
    required super.tenantId,
    required super.name,
    super.icon,
  });

  factory ExpenseCategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseCategoryModel(
      id: id,
      tenantId: map['tenantId'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'name': name,
      'icon': icon,
    };
  }
}
