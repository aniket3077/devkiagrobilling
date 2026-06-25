import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/product.dart';
import '../../../core/utils/tax_calculator.dart';
import 'billing_event.dart';
import 'billing_state.dart';

import '../../../domain/repositories/product_repository.dart';

import '../../../domain/entities/payment.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final ProductRepository? _productRepository;

  BillingBloc({ProductRepository? productRepository}) 
      : _productRepository = productRepository,
        super(const BillingState()) {
    on<AddProductToCart>(_onAddProduct);
    on<RemoveProductFromCart>(_onRemoveProduct);
    on<UpdateProductQuantity>(_onUpdateQuantity);
    on<SetCustomer>(_onSetCustomer);
    on<ClearCart>(_onClearCart);
    on<CreateInvoice>(_onCreateInvoice);
    on<AddProductByCode>(_onAddByCode);
    on<AddPayment>(_onAddPayment);
    on<RemovePayment>(_onRemovePayment);
  }

  void _onAddPayment(AddPayment event, Emitter<BillingState> emit) {
    final newPayments = List<PaymentDetail>.from(state.payments)..add(event.payment);
    final paidAmount = newPayments.fold<double>(0, (sum, p) => sum + p.amount);
    emit(state.copyWith(
      payments: newPayments,
      paidAmount: paidAmount,
      balanceAmount: state.grandTotal - paidAmount,
    ));
  }

  void _onRemovePayment(RemovePayment event, Emitter<BillingState> emit) {
    final newPayments = List<PaymentDetail>.from(state.payments)..removeAt(event.index);
    final paidAmount = newPayments.fold<double>(0, (sum, p) => sum + p.amount);
    emit(state.copyWith(
      payments: newPayments,
      paidAmount: paidAmount,
      balanceAmount: state.grandTotal - paidAmount,
    ));
  }

  void _onAddByCode(AddProductByCode event, Emitter<BillingState> emit) async {
    if (_productRepository == null) return;
    
    emit(state.copyWith(isProcessing: true));
    
    // In a real app, tenantId would come from an Auth state or service
    final result = await _productRepository!.getProductByCode('temp_tenant_id', event.code);
    
    result.fold(
      (failure) => emit(state.copyWith(isProcessing: false, error: failure.message)),
      (product) {
        if (product != null) {
          add(AddProductToCart(product));
          emit(state.copyWith(isProcessing: false));
        } else {
          emit(state.copyWith(isProcessing: false, error: 'Product not found'));
        }
      },
    );
  }

  void _onAddProduct(AddProductToCart event, Emitter<BillingState> emit) {
    final existingIndex = state.cartItems.indexWhere((item) => item.productId == event.product.id);
    List<InvoiceItem> newItems = List.from(state.cartItems);

    if (existingIndex >= 0) {
      final existingItem = newItems[existingIndex];
      final newQuantity = existingItem.quantity + event.quantity;
      newItems[existingIndex] = _createInvoiceItem(event.product, newQuantity);
    } else {
      newItems.add(_createInvoiceItem(event.product, event.quantity));
    }

    final totals = _calculateTotals(newItems);
    emit(state.copyWith(
      cartItems: newItems, 
      subTotal: totals['subTotal'],
      taxTotal: totals['taxTotal'],
      cgstTotal: totals['cgstTotal'],
      sgstTotal: totals['sgstTotal'],
      igstTotal: totals['igstTotal'],
      grandTotal: totals['grandTotal'],
      balanceAmount: totals['grandTotal'] - state.paidAmount,
    ));
  }

  void _onRemoveProduct(RemoveProductFromCart event, Emitter<BillingState> emit) {
    final newItems = state.cartItems.where((item) => item.productId != event.productId).toList();
    final totals = _calculateTotals(newItems);
    emit(state.copyWith(
      cartItems: newItems, 
      subTotal: totals['subTotal'],
      taxTotal: totals['taxTotal'],
      cgstTotal: totals['cgstTotal'],
      sgstTotal: totals['sgstTotal'],
      igstTotal: totals['igstTotal'],
      grandTotal: totals['grandTotal'],
      balanceAmount: totals['grandTotal'] - state.paidAmount,
    ));
  }

  void _onUpdateQuantity(UpdateProductQuantity event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCart(event.productId));
      return;
    }
    
    final index = state.cartItems.indexWhere((item) => item.productId == event.productId);
    if (index >= 0) {
      List<InvoiceItem> newItems = List.from(state.cartItems);
      final item = newItems[index];
      
      final taxResult = TaxCalculator.calculateExclusive(
        amount: item.unitPrice * event.quantity,
        taxRate: item.taxRate,
      );

      newItems[index] = InvoiceItem(
        productId: item.productId,
        name: item.name,
        quantity: event.quantity,
        unitPrice: item.unitPrice,
        taxRate: item.taxRate,
        cgst: taxResult.cgst,
        sgst: taxResult.sgst,
        igst: taxResult.igst,
        taxAmount: taxResult.totalTax,
        total: taxResult.totalAmount,
      );
      final totals = _calculateTotals(newItems);
      emit(state.copyWith(
        cartItems: newItems, 
        subTotal: totals['subTotal'],
        taxTotal: totals['taxTotal'],
        cgstTotal: totals['cgstTotal'],
        sgstTotal: totals['sgstTotal'],
        igstTotal: totals['igstTotal'],
        grandTotal: totals['grandTotal'],
        balanceAmount: totals['grandTotal'] - state.paidAmount,
      ));
    }
  }

  void _onSetCustomer(SetCustomer event, Emitter<BillingState> emit) {
    emit(state.copyWith(selectedCustomer: event.customer));
  }

  void _onClearCart(ClearCart event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  void _onCreateInvoice(CreateInvoice event, Emitter<BillingState> emit) async {
    if (state.cartItems.isEmpty) return;
    
    emit(state.copyWith(isProcessing: true));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(isProcessing: false, isSuccess: true));
  }

  InvoiceItem _createInvoiceItem(Product product, double quantity) {
    // Defaulting to exclusive calculation. 
    // In a full implementation, this could depend on product.isTaxInclusive
    final taxResult = TaxCalculator.calculateExclusive(
      amount: product.sellingPrice * quantity,
      taxRate: product.taxRate,
    );

    return InvoiceItem(
      productId: product.id,
      name: product.name,
      quantity: quantity,
      unitPrice: product.sellingPrice,
      taxRate: product.taxRate,
      cgst: taxResult.cgst,
      sgst: taxResult.sgst,
      igst: taxResult.igst,
      taxAmount: taxResult.totalTax,
      total: taxResult.totalAmount,
    );
  }

  Map<String, dynamic> _calculateTotals(List<InvoiceItem> items) {
    double subTotal = 0;
    double taxTotal = 0;
    double cgstTotal = 0;
    double sgstTotal = 0;
    double igstTotal = 0;
    double grandTotal = 0;

    for (var item in items) {
      subTotal += item.unitPrice * item.quantity;
      taxTotal += item.taxAmount;
      cgstTotal += item.cgst;
      sgstTotal += item.sgst;
      igstTotal += item.igst;
      grandTotal += item.total;
    }

    return {
      'subTotal': subTotal,
      'taxTotal': taxTotal,
      'cgstTotal': cgstTotal,
      'sgstTotal': sgstTotal,
      'igstTotal': igstTotal,
      'grandTotal': grandTotal,
    };
  }
}
