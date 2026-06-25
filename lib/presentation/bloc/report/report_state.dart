import 'package:equatable/equatable.dart';
import '../../../domain/entities/report_data.dart';

abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class SalesReportLoaded extends ReportState {
  final SalesReportData data;
  const SalesReportLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class ProfitLossReportLoaded extends ReportState {
  final ProfitLossReportData data;
  const ProfitLossReportLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class GstReportLoaded extends ReportState {
  final GstReportData data;
  const GstReportLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
}
