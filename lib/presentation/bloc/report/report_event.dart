import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class GenerateSalesReport extends ReportEvent {
  final String tenantId;
  final DateTime start;
  final DateTime end;
  const GenerateSalesReport(this.tenantId, this.start, this.end);
}

class GenerateProfitLossReport extends ReportEvent {
  final String tenantId;
  final DateTime start;
  final DateTime end;
  const GenerateProfitLossReport(this.tenantId, this.start, this.end);
}

class GenerateGstReport extends ReportEvent {
  final String tenantId;
  final DateTime start;
  final DateTime end;
  const GenerateGstReport(this.tenantId, this.start, this.end);
}
