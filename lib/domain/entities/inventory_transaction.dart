import 'package:equatable/equatable.dart';

enum TransactionType { stockIn, stockOut, adjustment, damaged }

class InventoryTransaction extends Equatable {
  final String id;
  final String tenantId;
  final String productId;
  final TransactionType type;
  final double quantity;
  final String reason;
  final DateTime date;
  final String? referenceId; // e.g., Invoice ID or Purchase Order ID

  const InventoryTransaction({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.date,
    this.referenceId,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        productId,
        type,
        quantity,
        reason,
        date,
        referenceId,
      ];
}
