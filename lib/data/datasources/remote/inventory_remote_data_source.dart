import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/inventory_transaction_model.dart';
import '../../../domain/entities/inventory_transaction.dart';
import '../../../services/notification_service.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryTransactionModel>> getTransactionsByProduct(String productId);
  Future<List<InventoryTransactionModel>> getRecentTransactions(String tenantId);
  Future<void> addTransaction(InventoryTransactionModel transaction);
  Future<List<Map<String, dynamic>>> getLowStockProducts(String tenantId);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final FirebaseFirestore _firestore;
  final NotificationService? _notificationService;

  InventoryRemoteDataSourceImpl(this._firestore, {NotificationService? notificationService}) 
      : _notificationService = notificationService;

  @override
  Future<List<InventoryTransactionModel>> getTransactionsByProduct(String productId) async {
    final snapshot = await _firestore
        .collection('inventory_transactions')
        .where('productId', isEqualTo: productId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => InventoryTransactionModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<InventoryTransactionModel>> getRecentTransactions(String tenantId) async {
    final snapshot = await _firestore
        .collection('inventory_transactions')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('date', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => InventoryTransactionModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> addTransaction(InventoryTransactionModel transaction) async {
    final batch = _firestore.batch();
    
    // 1. Add transaction log
    final txRef = _firestore.collection('inventory_transactions').doc();
    batch.set(txRef, transaction.toMap());
    
    // 2. Update product stock
    final productRef = _firestore.collection('products').doc(transaction.productId);
    
    double stockChange = transaction.quantity;
    if (transaction.type == TransactionType.stockOut || transaction.type == TransactionType.damaged) {
      stockChange = -transaction.quantity;
    }
    
    batch.update(productRef, {
      'currentStock': FieldValue.increment(stockChange),
    });
    
    await batch.commit();

    // Check for low stock after transaction
    if (_notificationService != null) {
      final productDoc = await productRef.get();
      final data = productDoc.data();
      if (data != null) {
        final currentStock = (data['currentStock'] ?? 0.0).toDouble();
        final threshold = (data['lowStockThreshold'] ?? 0.0).toDouble();
        if (currentStock <= threshold) {
          _notificationService?.showLowStockAlert(data['name'] ?? 'Product', currentStock);
        }
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLowStockProducts(String tenantId) async {
    // In Firestore, we can't easily compare two fields in a query without structured data.
    // However, for this MVP, we will fetch products and filter or use a pre-calculated flag.
    // Better way: maintain a 'isLowStock' boolean in Cloud Functions when stock changes.
    final snapshot = await _firestore
        .collection('products')
        .where('tenantId', isEqualTo: tenantId)
        .get();
        
    return snapshot.docs
        .map((doc) => doc.data())
        .where((data) => (data['currentStock'] ?? 0) <= (data['lowStockThreshold'] ?? 0))
        .toList();
  }
}
