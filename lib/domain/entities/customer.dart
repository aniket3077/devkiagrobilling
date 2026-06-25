import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? address;
  final double creditBalance; // positive for credit (customer owes), negative for advance
  final int loyaltyPoints;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.address,
    required this.creditBalance,
    required this.loyaltyPoints,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        phoneNumber,
        email,
        address,
        creditBalance,
        loyaltyPoints,
        createdAt,
      ];
}
