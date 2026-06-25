import 'package:equatable/equatable.dart';
import '../../../domain/entities/customer.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  final String tenantId;
  const LoadCustomers(this.tenantId);
}

class SearchCustomers extends CustomerEvent {
  final String tenantId;
  final String query;
  const SearchCustomers(this.tenantId, this.query);
}

class AddCustomerEvent extends CustomerEvent {
  final Customer customer;
  const AddCustomerEvent(this.customer);
}

class UpdateCustomerEvent extends CustomerEvent {
  final Customer customer;
  const UpdateCustomerEvent(this.customer);
}

class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;
  const DeleteCustomerEvent(this.customerId);
}
