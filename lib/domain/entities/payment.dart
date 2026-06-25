import 'package:equatable/equatable.dart';

enum PaymentMode { cash, upi, card, credit, other }

class PaymentDetail extends Equatable {
  final PaymentMode mode;
  final double amount;
  final String? transactionId;
  final DateTime date;

  const PaymentDetail({
    required this.mode,
    required this.amount,
    this.transactionId,
    required this.date,
  });

  @override
  List<Object?> get props => [mode, amount, transactionId, date];
}
