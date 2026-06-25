import 'package:equatable/equatable.dart';

class SalesReportData extends Equatable {
  final double totalSales;
  final int invoiceCount;
  final double averageOrderValue;
  final Map<String, double> salesByPaymentMode;
  final List<TimeSeriesData> revenueTrend;
  final List<RecentTransaction> recentTransactions;
  final List<TopProductItem> topProducts;

  const SalesReportData({
    required this.totalSales,
    required this.invoiceCount,
    required this.averageOrderValue,
    required this.salesByPaymentMode,
    required this.revenueTrend,
    required this.recentTransactions,
    required this.topProducts,
  });

  @override
  List<Object?> get props => [
        totalSales,
        invoiceCount,
        averageOrderValue,
        salesByPaymentMode,
        revenueTrend,
        recentTransactions,
        topProducts,
      ];
}

class RecentTransaction extends Equatable {
  final String customerName;
  final String invoiceId;
  final double amount;
  final String status;
  final DateTime date;

  const RecentTransaction({
    required this.customerName,
    required this.invoiceId,
    required this.amount,
    required this.status,
    required this.date,
  });

  @override
  List<Object?> get props => [customerName, invoiceId, amount, status, date];
}

class TopProductItem extends Equatable {
  final String name;
  final double quantitySold;
  final double revenue;

  const TopProductItem({
    required this.name,
    required this.quantitySold,
    required this.revenue,
  });

  @override
  List<Object?> get props => [name, quantitySold, revenue];
}

class TimeSeriesData extends Equatable {
  final DateTime date;
  final double value;

  const TimeSeriesData(this.date, this.value);

  @override
  List<Object?> get props => [date, value];
}

class ProfitLossReportData extends Equatable {
  final double totalRevenue;
  final double totalExpenses;
  final double grossProfit;
  final double netProfit;

  const ProfitLossReportData({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.grossProfit,
    required this.netProfit,
  });

  @override
  List<Object?> get props => [totalRevenue, totalExpenses, grossProfit, netProfit];
}

class GstReportData extends Equatable {
  final double taxableAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalGst;

  const GstReportData({
    required this.taxableAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalGst,
  });

  @override
  List<Object?> get props => [taxableAmount, cgst, sgst, igst, totalGst];
}
