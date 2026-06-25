import 'package:equatable/equatable.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/payment.dart';

class BillingState extends Equatable {
  final List<InvoiceItem> cartItems;
  final Customer? selectedCustomer;
  final List<PaymentDetail> payments;
  final double subTotal;
  final double cgstTotal;
  final double sgstTotal;
  final double igstTotal;
  final double taxTotal;
  final double grandTotal;
  final double paidAmount;
  final double balanceAmount;
  final bool isProcessing;
  final String? error;
  final bool isSuccess;

  const BillingState({
    this.cartItems = const [],
    this.selectedCustomer,
    this.payments = const [],
    this.subTotal = 0.0,
    this.cgstTotal = 0.0,
    this.sgstTotal = 0.0,
    this.igstTotal = 0.0,
    this.taxTotal = 0.0,
    this.grandTotal = 0.0,
    this.paidAmount = 0.0,
    this.balanceAmount = 0.0,
    this.isProcessing = false,
    this.error,
    this.isSuccess = false,
  });

  BillingState copyWith({
    List<InvoiceItem>? cartItems,
    Customer? selectedCustomer,
    List<PaymentDetail>? payments,
    double? subTotal,
    double? cgstTotal,
    double? sgstTotal,
    double? igstTotal,
    double? taxTotal,
    double? grandTotal,
    double? paidAmount,
    double? balanceAmount,
    bool? isProcessing,
    String? error,
    bool? isSuccess,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      payments: payments ?? this.payments,
      subTotal: subTotal ?? this.subTotal,
      cgstTotal: cgstTotal ?? this.cgstTotal,
      sgstTotal: sgstTotal ?? this.sgstTotal,
      igstTotal: igstTotal ?? this.igstTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      isSuccess: isSuccess ?? false,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        selectedCustomer,
        payments,
        subTotal,
        cgstTotal,
        sgstTotal,
        igstTotal,
        taxTotal,
        grandTotal,
        paidAmount,
        balanceAmount,
        isProcessing,
        error,
        isSuccess,
      ];
}
