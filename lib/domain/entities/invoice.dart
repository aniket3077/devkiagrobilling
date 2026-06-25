import 'package:equatable/equatable.dart';
import 'payment.dart';

class Invoice extends Equatable {
  final String id;
  final String tenantId;
  final String branchId;
  final String invoiceNumber;
  final String? customerId;
  final String customerName;
  final String staffId;
  final DateTime date;
  final List<InvoiceItem> items;
  final double subTotal; // Total base amount before tax
  final double cgstTotal;
  final double sgstTotal;
  final double igstTotal;
  final double taxTotal;
  final double discount;
  final double grandTotal;
  final double paidAmount;
  final double balanceAmount;
  final String paymentStatus; // 'paid', 'partial', 'unpaid', 'credit'
  final List<PaymentDetail> payments;
  final bool isInterstate;

  const Invoice({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.invoiceNumber,
    this.customerId,
    required this.customerName,
    required this.staffId,
    required this.date,
    required this.items,
    required this.subTotal,
    required this.cgstTotal,
    required this.sgstTotal,
    required this.igstTotal,
    required this.taxTotal,
    required this.discount,
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceAmount,
    required this.paymentStatus,
    required this.payments,
    this.isInterstate = false,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        branchId,
        invoiceNumber,
        customerId,
        customerName,
        staffId,
        date,
        items,
        subTotal,
        cgstTotal,
        sgstTotal,
        igstTotal,
        taxTotal,
        discount,
        grandTotal,
        paidAmount,
        balanceAmount,
        paymentStatus,
        payments,
        isInterstate,
      ];
}

class InvoiceItem extends Equatable {
  final String productId;
  final String name;
  final double quantity;
  final double unitPrice; // Base price per unit
  final double taxRate;
  final double cgst;
  final double sgst;
  final double igst;
  final double taxAmount;
  final double total; // Final amount for this item (Base * Qty + Tax)

  const InvoiceItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.taxAmount,
    required this.total,
  });

  @override
  List<Object?> get props => [
        productId,
        name,
        quantity,
        unitPrice,
        taxRate,
        cgst,
        sgst,
        igst,
        taxAmount,
        total,
      ];
}
