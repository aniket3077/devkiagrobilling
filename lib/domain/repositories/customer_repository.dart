import 'package:fpdart/fpdart.dart';
import '../entities/customer.dart';
import '../../core/error/failures.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers(String tenantId);
  Future<Either<Failure, List<Customer>>> searchCustomers(String tenantId, String query);
  Future<Either<Failure, Customer>> getCustomerById(String customerId);
  Future<Either<Failure, Unit>> addCustomer(Customer customer);
  Future<Either<Failure, Unit>> updateCustomer(Customer customer);
  Future<Either<Failure, Unit>> deleteCustomer(String customerId);
  Future<Either<Failure, Unit>> updateCreditBalance(String customerId, double amount);
  Future<Either<Failure, Unit>> updateLoyaltyPoints(String customerId, int points);
}
