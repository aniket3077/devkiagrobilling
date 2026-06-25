import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository customerRepository;

  CustomerBloc({required this.customerRepository}) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    final result = await customerRepository.getCustomers(event.tenantId);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(CustomersLoaded(customers)),
    );
  }

  Future<void> _onSearchCustomers(SearchCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    final result = await customerRepository.searchCustomers(event.tenantId, event.query);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(CustomersLoaded(customers)),
    );
  }

  Future<void> _onAddCustomer(AddCustomerEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    final result = await customerRepository.addCustomer(event.customer);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(CustomerOperationSuccess()),
    );
  }

  Future<void> _onUpdateCustomer(UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    final result = await customerRepository.updateCustomer(event.customer);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(CustomerOperationSuccess()),
    );
  }

  Future<void> _onDeleteCustomer(DeleteCustomerEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    final result = await customerRepository.deleteCustomer(event.customerId);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(CustomerOperationSuccess()),
    );
  }
}
