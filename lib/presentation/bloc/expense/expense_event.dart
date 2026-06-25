import 'package:equatable/equatable.dart';
import '../../../domain/entities/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final String tenantId;
  final DateTime? startDate;
  final DateTime? endDate;
  const LoadExpenses(this.tenantId, {this.startDate, this.endDate});
}

class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;
  const AddExpenseEvent(this.expense);
}

class UpdateExpenseEvent extends ExpenseEvent {
  final Expense expense;
  const UpdateExpenseEvent(this.expense);
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String expenseId;
  const DeleteExpenseEvent(this.expenseId);
}

class LoadExpenseSummary extends ExpenseEvent {
  final String tenantId;
  final DateTime month;
  const LoadExpenseSummary(this.tenantId, this.month);
}
