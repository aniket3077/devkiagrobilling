import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/remote/expense_remote_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Expense>>> getExpenses(String tenantId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final expenses = await remoteDataSource.getExpenses(tenantId, startDate: startDate, endDate: endDate);
      return Right(expenses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addExpense(Expense expense) async {
    try {
      await remoteDataSource.addExpense(_toModel(expense));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateExpense(Expense expense) async {
    try {
      await remoteDataSource.updateExpense(_toModel(expense));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExpense(String expenseId) async {
    try {
      await remoteDataSource.deleteExpense(expenseId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseCategory>>> getCategories(String tenantId) async {
    try {
      final categories = await remoteDataSource.getCategories(tenantId);
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addCategory(ExpenseCategory category) async {
    try {
      await remoteDataSource.addCategory(ExpenseCategoryModel(
        id: category.id,
        tenantId: category.tenantId,
        name: category.name,
        icon: category.icon,
      ));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getExpenseSummary(String tenantId, DateTime month) async {
    try {
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);
      final expenses = await remoteDataSource.getExpenses(tenantId, startDate: startDate, endDate: endDate);
      
      final Map<String, double> summary = {};
      for (var expense in expenses) {
        summary[expense.categoryName] = (summary[expense.categoryName] ?? 0) + expense.amount;
      }
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  ExpenseModel _toModel(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      tenantId: expense.tenantId,
      categoryId: expense.categoryId,
      categoryName: expense.categoryName,
      amount: expense.amount,
      description: expense.description,
      date: expense.date,
      paymentMethod: expense.paymentMethod,
      isRecurring: expense.isRecurring,
      frequency: expense.frequency,
    );
  }
}
