import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository inventoryRepository;

  InventoryBloc({required this.inventoryRepository}) : super(InventoryInitial()) {
    on<LoadRecentTransactions>(_onLoadRecentTransactions);
    on<AddInventoryTransaction>(_onAddTransaction);
    on<LoadLowStockAlerts>(_onLoadLowStockAlerts);
  }

  Future<void> _onLoadRecentTransactions(LoadRecentTransactions event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    final result = await inventoryRepository.getRecentTransactions(event.tenantId);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  Future<void> _onAddTransaction(AddInventoryTransaction event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    final result = await inventoryRepository.addTransaction(event.transaction);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) => emit(InventoryOperationSuccess()),
    );
  }

  Future<void> _onLoadLowStockAlerts(LoadLowStockAlerts event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    final result = await inventoryRepository.getLowStockProducts(event.tenantId);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (products) => emit(LowStockLoaded(products)),
    );
  }
}
