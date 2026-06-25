import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;

  ExpenseBloc({required this.expenseRepository}) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<LoadExpenseSummary>(_onLoadExpenseSummary);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    final result = await expenseRepository.getExpenses(event.tenantId, startDate: event.startDate, endDate: event.endDate);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) => emit(ExpensesLoaded(expenses)),
    );
  }

  Future<void> _onAddExpense(AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    final result = await expenseRepository.addExpense(event.expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => emit(ExpenseOperationSuccess()),
    );
  }

  Future<void> _onUpdateExpense(UpdateExpenseEvent event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    final result = await expenseRepository.updateExpense(event.expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => emit(ExpenseOperationSuccess()),
    );
  }

  Future<void> _onDeleteExpense(DeleteExpenseEvent event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    final result = await expenseRepository.deleteExpense(event.expenseId);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => emit(ExpenseOperationSuccess()),
    );
  }

  Future<void> _onLoadExpenseSummary(LoadExpenseSummary event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    final result = await expenseRepository.getExpenseSummary(event.tenantId, event.month);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (summary) => emit(ExpenseSummaryLoaded(summary)),
    );
  }
}
