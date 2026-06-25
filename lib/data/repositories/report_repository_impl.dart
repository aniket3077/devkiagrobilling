import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, SalesReportData>> getSalesReport(String tenantId, DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where('tenantId', isEqualTo: tenantId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      double totalSales = 0;
      Map<String, double> modeMap = {};
      Map<DateTime, double> trendMap = {};
      List<RecentTransaction> recentTx = [];
      Map<String, Map<String, dynamic>> productMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['grandTotal'] ?? 0.0).toDouble();
        totalSales += amount;
        
        final method = data['paymentMethod'] ?? 'Other';
        modeMap[method] = (modeMap[method] ?? 0.0) + amount;

        final date = (data['date'] as Timestamp).toDate();
        final day = DateTime(date.year, date.month, date.day);
        trendMap[day] = (trendMap[day] ?? 0.0) + amount;

        // Extract recent transaction
        recentTx.add(RecentTransaction(
          customerName: data['customerName'] ?? 'Walk-in',
          invoiceId: data['invoiceNumber'] ?? doc.id,
          amount: amount,
          status: data['paymentStatus'] ?? 'Paid',
          date: date,
        ));

        // Extract items for top products
        final items = data['items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final name = item['name'] ?? 'Unknown Product';
          final qty = (item['quantity'] ?? 0.0).toDouble();
          final total = (item['total'] ?? 0.0).toDouble();

          if (!productMap.containsKey(name)) {
            productMap[name] = {'name': name, 'quantity': 0.0, 'revenue': 0.0};
          }
          productMap[name]!['quantity'] += qty;
          productMap[name]!['revenue'] += total;
        }
      }

      final revenueTrend = trendMap.entries
          .map((e) => TimeSeriesData(e.key, e.value))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      recentTx.sort((a, b) => b.date.compareTo(a.date));
      final recentTransactions = recentTx.length > 5 ? recentTx.sublist(0, 5) : recentTx;

      final topProductsList = productMap.values.map((p) {
        return TopProductItem(
          name: p['name'],
          quantitySold: p['quantity'],
          revenue: p['revenue'],
        );
      }).toList();
      topProductsList.sort((a, b) => b.revenue.compareTo(a.revenue));
      final topProducts = topProductsList.length > 5 ? topProductsList.sublist(0, 5) : topProductsList;

      return Right(SalesReportData(
        totalSales: totalSales,
        invoiceCount: snapshot.docs.length,
        averageOrderValue: snapshot.docs.isEmpty ? 0 : totalSales / snapshot.docs.length,
        salesByPaymentMode: modeMap,
        revenueTrend: revenueTrend,
        recentTransactions: recentTransactions,
        topProducts: topProducts,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfitLossReportData>> getProfitLossReport(String tenantId, DateTime start, DateTime end) async {
    try {
      final salesResult = await getSalesReport(tenantId, start, end);
      return await salesResult.fold(
        (l) => Left(l),
        (salesData) async {
          final expenseSnapshot = await _firestore
              .collection('expenses')
              .where('tenantId', isEqualTo: tenantId)
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
              .get();

          double totalExpenses = 0;
          for (var doc in expenseSnapshot.docs) {
            totalExpenses += (doc.data()['amount'] ?? 0.0).toDouble();
          }

          return Right(ProfitLossReportData(
            totalRevenue: salesData.totalSales,
            totalExpenses: totalExpenses,
            grossProfit: salesData.totalSales, // Simplified
            netProfit: salesData.totalSales - totalExpenses,
          ));
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GstReportData>> getGstReport(String tenantId, DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where('tenantId', isEqualTo: tenantId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      double taxable = 0;
      double cgst = 0;
      double sgst = 0;
      double igst = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        taxable += (data['subTotal'] ?? 0.0).toDouble();
        cgst += (data['cgstTotal'] ?? 0.0).toDouble();
        sgst += (data['sgstTotal'] ?? 0.0).toDouble();
        igst += (data['igstTotal'] ?? 0.0).toDouble();
      }

      return Right(GstReportData(
        taxableAmount: taxable,
        cgst: cgst,
        sgst: sgst,
        igst: igst,
        totalGst: cgst + sgst + igst,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopProducts(String tenantId, DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where('tenantId', isEqualTo: tenantId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      Map<String, Map<String, dynamic>> productMap = {};

      for (var doc in snapshot.docs) {
        final items = doc.data()['items'] as List<dynamic>;
        for (var item in items) {
          final id = item['productId'];
          final name = item['name'];
          final qty = (item['quantity'] ?? 0.0).toDouble();
          final total = (item['total'] ?? 0.0).toDouble();

          if (!productMap.containsKey(id)) {
            productMap[id] = {'name': name, 'quantity': 0.0, 'revenue': 0.0};
          }
          productMap[id]!['quantity'] += qty;
          productMap[id]!['revenue'] += total;
        }
      }

      var sortedList = productMap.values.toList();
      sortedList.sort((a, b) => b['revenue'].compareTo(a['revenue']));
      return Right(sortedList);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerSales(String tenantId, DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where('tenantId', isEqualTo: tenantId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      Map<String, Map<String, dynamic>> customerMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = data['customerName'] ?? 'Walk-in';
        final total = (data['grandTotal'] ?? 0.0).toDouble();

        if (!customerMap.containsKey(name)) {
          customerMap[name] = {'name': name, 'orderCount': 0, 'totalValue': 0.0};
        }
        customerMap[name]!['orderCount'] += 1;
        customerMap[name]!['totalValue'] += total;
      }

      return Right(customerMap.values.toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
