import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/remote/customer_remote_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Customer>>> getCustomers(String tenantId) async {
    try {
      final customers = await remoteDataSource.getCustomers(tenantId);
      return Right(customers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> searchCustomers(String tenantId, String query) async {
    try {
      final customers = await remoteDataSource.searchCustomers(tenantId, query);
      return Right(customers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(String customerId) async {
    try {
      final customer = await remoteDataSource.getCustomerById(customerId);
      return Right(customer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addCustomer(Customer customer) async {
    try {
      await remoteDataSource.addCustomer(_toModel(customer));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCustomer(Customer customer) async {
    try {
      await remoteDataSource.updateCustomer(_toModel(customer));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCustomer(String customerId) async {
    try {
      await remoteDataSource.deleteCustomer(customerId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCreditBalance(String customerId, double amount) async {
    try {
      await remoteDataSource.updateCreditBalance(customerId, amount);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateLoyaltyPoints(String customerId, int points) async {
    try {
      await remoteDataSource.updateLoyaltyPoints(customerId, points);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  CustomerModel _toModel(Customer customer) {
    return CustomerModel(
      id: customer.id,
      tenantId: customer.tenantId,
      name: customer.name,
      phoneNumber: customer.phoneNumber,
      email: customer.email,
      address: customer.address,
      creditBalance: customer.creditBalance,
      loyaltyPoints: customer.loyaltyPoints,
      createdAt: customer.createdAt,
    );
  }
}
