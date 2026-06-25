import 'package:equatable/equatable.dart';
import '../../../domain/entities/employee.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();
  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class AttendanceLoaded extends EmployeeState {
  final List<Attendance> attendanceList;
  const AttendanceLoaded(this.attendanceList);
  @override
  List<Object?> get props => [attendanceList];
}

class SalaryHistoryLoaded extends EmployeeState {
  final List<SalaryRecord> history;
  const SalaryHistoryLoaded(this.history);
}

class PerformanceLoaded extends EmployeeState {
  final Map<String, dynamic> performance;
  const PerformanceLoaded(this.performance);
}

class EmployeeError extends EmployeeState {
  final String message;
  const EmployeeError(this.message);
}

class EmployeeOperationSuccess extends EmployeeState {}
