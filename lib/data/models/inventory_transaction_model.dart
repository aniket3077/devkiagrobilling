import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_transaction.dart';

class InventoryTransactionModel extends InventoryTransaction {
  const InventoryTransactionModel({
    required super.id,
    required super.tenantId,
    required super.productId,
    required super.type,
    required super.quantity,
    required super.reason,
    required super.date,
    super.referenceId,
  });

  factory InventoryTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return InventoryTransactionModel(
      id: id,
      tenantId: map['tenantId'] ?? '',
      productId: map['productId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'adjustment'),
        orElse: () => TransactionType.adjustment,
      ),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      reason: map['reason'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      referenceId: map['referenceId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'productId': productId,
      'type': type.name,
      'quantity': quantity,
      'reason': reason,
      'date': Timestamp.fromDate(date),
      'referenceId': referenceId,
    };
  }
}
