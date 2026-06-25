import 'package:equatable/equatable.dart';
import '../../../domain/entities/expense.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpensesLoaded extends ExpenseState {
  final List<Expense> expenses;
  const ExpensesLoaded(this.expenses);
  @override
  List<Object?> get props => [expenses];
}

class ExpenseSummaryLoaded extends ExpenseState {
  final Map<String, double> summary;
  const ExpenseSummaryLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
}

class ExpenseOperationSuccess extends ExpenseState {}
