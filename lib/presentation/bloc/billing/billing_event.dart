import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/customer.dart';

import '../../../domain/entities/payment.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();
  @override
  List<Object?> get props => [];
}

class AddProductToCart extends BillingEvent {
  final Product product;
  final double quantity;
  const AddProductToCart(this.product, {this.quantity = 1});
}

class RemoveProductFromCart extends BillingEvent {
  final String productId;
  const RemoveProductFromCart(this.productId);
}

class UpdateProductQuantity extends BillingEvent {
  final String productId;
  final double quantity;
  const UpdateProductQuantity(this.productId, this.quantity);
}

class SetCustomer extends BillingEvent {
  final Customer? customer;
  const SetCustomer(this.customer);
}

class ClearCart extends BillingEvent {}

class CreateInvoice extends BillingEvent {}

class AddPayment extends BillingEvent {
  final PaymentDetail payment;
  const AddPayment(this.payment);
}

class RemovePayment extends BillingEvent {
  final int index;
  const RemovePayment(this.index);
}

class AddProductByCode extends BillingEvent {
  final String code;
  const AddProductByCode(this.code);
}
