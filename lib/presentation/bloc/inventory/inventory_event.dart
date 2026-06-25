import 'package:equatable/equatable.dart';
import '../../../domain/entities/inventory_transaction.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecentTransactions extends InventoryEvent {
  final String tenantId;
  const LoadRecentTransactions(this.tenantId);
}

class AddInventoryTransaction extends InventoryEvent {
  final InventoryTransaction transaction;
  const AddInventoryTransaction(this.transaction);
}

class LoadLowStockAlerts extends InventoryEvent {
  final String tenantId;
  const LoadLowStockAlerts(this.tenantId);
}
