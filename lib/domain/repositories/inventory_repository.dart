import 'package:fpdart/fpdart.dart';
import '../entities/inventory_transaction.dart';
import '../../core/error/failures.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<InventoryTransaction>>> getTransactionsByProduct(String productId);
  Future<Either<Failure, List<InventoryTransaction>>> getRecentTransactions(String tenantId);
  Future<Either<Failure, Unit>> addTransaction(InventoryTransaction transaction);
  Future<Either<Failure, List<Map<String, dynamic>>>> getLowStockProducts(String tenantId);
}
