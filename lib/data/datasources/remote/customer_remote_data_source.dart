import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/customer_model.dart';
import '../../../domain/entities/customer.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers(String tenantId);
  Future<List<CustomerModel>> searchCustomers(String tenantId, String query);
  Future<CustomerModel> getCustomerById(String customerId);
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);
  Future<void> updateCreditBalance(String customerId, double amount);
  Future<void> updateLoyaltyPoints(String customerId, int points);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final FirebaseFirestore _firestore;

  CustomerRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<CustomerModel>> getCustomers(String tenantId) async {
    final snapshot = await _firestore
        .collection('customers')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) => CustomerModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String tenantId, String query) async {
    // Search by name or phone number
    final nameQuery = await _firestore
        .collection('customers')
        .where('tenantId', isEqualTo: tenantId)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    
    final phoneQuery = await _firestore
        .collection('customers')
        .where('tenantId', isEqualTo: tenantId)
        .where('phoneNumber', isGreaterThanOrEqualTo: query)
        .where('phoneNumber', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    final results = [...nameQuery.docs, ...phoneQuery.docs];
    final seenIds = <String>{};
    return results
        .where((doc) => seenIds.add(doc.id))
        .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<CustomerModel> getCustomerById(String customerId) async {
    final doc = await _firestore.collection('customers').doc(customerId).get();
    if (!doc.exists) throw Exception('Customer not found');
    return CustomerModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    await _firestore.collection('customers').doc(customer.id).set(customer.toMap());
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await _firestore.collection('customers').doc(customer.id).update(customer.toMap());
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    await _firestore.collection('customers').doc(customerId).delete();
  }

  @override
  Future<void> updateCreditBalance(String customerId, double amount) async {
    await _firestore.collection('customers').doc(customerId).update({
      'creditBalance': FieldValue.increment(amount),
    });
  }

  @override
  Future<void> updateLoyaltyPoints(String customerId, int points) async {
    await _firestore.collection('customers').doc(customerId).update({
      'loyaltyPoints': FieldValue.increment(points),
    });
  }
}
