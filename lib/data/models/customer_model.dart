import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.tenantId,
    required super.name,
    required super.phoneNumber,
    super.email,
    super.address,
    required super.creditBalance,
    required super.loyaltyPoints,
    required super.createdAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      id: id,
      tenantId: map['tenantId'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      address: map['address'],
      creditBalance: (map['creditBalance'] ?? 0.0).toDouble(),
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'creditBalance': creditBalance,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
