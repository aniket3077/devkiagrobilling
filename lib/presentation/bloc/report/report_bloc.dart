import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository reportRepository;

  ReportBloc({required this.reportRepository}) : super(ReportInitial()) {
    on<GenerateSalesReport>(_onGenerateSalesReport);
    on<GenerateProfitLossReport>(_onGenerateProfitLossReport);
    on<GenerateGstReport>(_onGenerateGstReport);
  }

  Future<void> _onGenerateSalesReport(GenerateSalesReport event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await reportRepository.getSalesReport(event.tenantId, event.start, event.end);
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (data) => emit(SalesReportLoaded(data)),
    );
  }

  Future<void> _onGenerateProfitLossReport(GenerateProfitLossReport event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await reportRepository.getProfitLossReport(event.tenantId, event.start, event.end);
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (data) => emit(ProfitLossReportLoaded(data)),
    );
  }

  Future<void> _onGenerateGstReport(GenerateGstReport event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await reportRepository.getGstReport(event.tenantId, event.start, event.end);
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (data) => emit(GstReportLoaded(data)),
    );
  }
}
