import 'package:fpdart/fpdart.dart';
import '../entities/report_data.dart';
import '../../core/error/failures.dart';

abstract class ReportRepository {
  Future<Either<Failure, SalesReportData>> getSalesReport(String tenantId, DateTime start, DateTime end);
  Future<Either<Failure, ProfitLossReportData>> getProfitLossReport(String tenantId, DateTime start, DateTime end);
  Future<Either<Failure, GstReportData>> getGstReport(String tenantId, DateTime start, DateTime end);
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopProducts(String tenantId, DateTime start, DateTime end);
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerSales(String tenantId, DateTime start, DateTime end);
}
