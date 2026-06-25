import 'package:equatable/equatable.dart';
import '../../../domain/entities/inventory_transaction.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class TransactionsLoaded extends InventoryState {
  final List<InventoryTransaction> transactions;
  const TransactionsLoaded(this.transactions);
  @override
  List<Object?> get props => [transactions];
}

class LowStockLoaded extends InventoryState {
  final List<Map<String, dynamic>> products;
  const LowStockLoaded(this.products);
}

class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);
}

class InventoryOperationSuccess extends InventoryState {}
