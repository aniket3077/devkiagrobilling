import 'package:fpdart/fpdart.dart';
import '../entities/expense.dart';
import '../../core/error/failures.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses(String tenantId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, Unit>> addExpense(Expense expense);
  Future<Either<Failure, Unit>> updateExpense(Expense expense);
  Future<Either<Failure, Unit>> deleteExpense(String expenseId);
  
  Future<Either<Failure, List<ExpenseCategory>>> getCategories(String tenantId);
  Future<Either<Failure, Unit>> addCategory(ExpenseCategory category);
  
  Future<Either<Failure, Map<String, double>>> getExpenseSummary(String tenantId, DateTime month);
}
