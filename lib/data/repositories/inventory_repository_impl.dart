import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/remote/inventory_remote_data_source.dart';
import '../models/inventory_transaction_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<InventoryTransaction>>> getTransactionsByProduct(String productId) async {
    try {
      final transactions = await remoteDataSource.getTransactionsByProduct(productId);
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryTransaction>>> getRecentTransactions(String tenantId) async {
    try {
      final transactions = await remoteDataSource.getRecentTransactions(tenantId);
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addTransaction(InventoryTransaction transaction) async {
    try {
      await remoteDataSource.addTransaction(InventoryTransactionModel(
        id: transaction.id,
        tenantId: transaction.tenantId,
        productId: transaction.productId,
        type: transaction.type,
        quantity: transaction.quantity,
        reason: transaction.reason,
        date: transaction.date,
        referenceId: transaction.referenceId,
      ));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getLowStockProducts(String tenantId) async {
    try {
      final products = await remoteDataSource.getLowStockProducts(tenantId);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
