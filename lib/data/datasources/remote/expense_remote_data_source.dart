import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses(String tenantId, {DateTime? startDate, DateTime? endDate});
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Future<List<ExpenseCategoryModel>> getCategories(String tenantId);
  Future<void> addCategory(ExpenseCategoryModel category);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExpenseRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ExpenseModel>> getExpenses(String tenantId, {DateTime? startDate, DateTime? endDate}) async {
    Query query = _firestore.collection('expenses').where('tenantId', isEqualTo: tenantId);

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore.collection('expenses').doc(expense.id.isEmpty ? null : expense.id).set(expense.toMap());
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await _firestore.collection('expenses').doc(expense.id).update(expense.toMap());
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }

  @override
  Future<List<ExpenseCategoryModel>> getCategories(String tenantId) async {
    final snapshot = await _firestore.collection('expense_categories').where('tenantId', isEqualTo: tenantId).get();
    return snapshot.docs.map((doc) => ExpenseCategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Future<void> addCategory(ExpenseCategoryModel category) async {
    await _firestore.collection('expense_categories').doc(category.id.isEmpty ? null : category.id).set(category.toMap());
  }
}
