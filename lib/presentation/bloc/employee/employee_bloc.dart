import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/employee_repository.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository employeeRepository;

  EmployeeBloc({required this.employeeRepository}) : super(EmployeeInitial()) {
    on<LoadAttendance>(_onLoadAttendance);
    on<MarkAttendanceEvent>(_onMarkAttendance);
    on<LoadSalaryHistory>(_onLoadSalaryHistory);
    on<LoadPerformance>(_onLoadPerformance);
  }

  Future<void> _onLoadAttendance(LoadAttendance event, Emitter<EmployeeState> emit) async {
    emit(EmployeeLoading());
    final result = await employeeRepository.getAttendance(event.tenantId, event.branchId, event.date);
    result.fold(
      (failure) => emit(EmployeeError(failure.message)),
      (list) => emit(AttendanceLoaded(list)),
    );
  }

  Future<void> _onMarkAttendance(MarkAttendanceEvent event, Emitter<EmployeeState> emit) async {
    final result = await employeeRepository.markAttendance(event.attendance);
    result.fold(
      (failure) => emit(EmployeeError(failure.message)),
      (_) => emit(EmployeeOperationSuccess()),
    );
  }

  Future<void> _onLoadSalaryHistory(LoadSalaryHistory event, Emitter<EmployeeState> emit) async {
    emit(EmployeeLoading());
    final result = await employeeRepository.getSalaryHistory(event.employeeId);
    result.fold(
      (failure) => emit(EmployeeError(failure.message)),
      (history) => emit(SalaryHistoryLoaded(history)),
    );
  }

  Future<void> _onLoadPerformance(LoadPerformance event, Emitter<EmployeeState> emit) async {
    emit(EmployeeLoading());
    final result = await employeeRepository.getEmployeePerformance(event.employeeId, event.start, event.end);
    result.fold(
      (failure) => emit(EmployeeError(failure.message)),
      (performance) => emit(PerformanceLoaded(performance)),
    );
  }
}
