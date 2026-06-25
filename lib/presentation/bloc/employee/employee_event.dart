import 'package:equatable/equatable.dart';
import '../../../domain/entities/employee.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();
  @override
  List<Object?> get props => [];
}

class LoadAttendance extends EmployeeEvent {
  final String tenantId;
  final String branchId;
  final DateTime date;
  const LoadAttendance(this.tenantId, this.branchId, this.date);
}

class MarkAttendanceEvent extends EmployeeEvent {
  final Attendance attendance;
  const MarkAttendanceEvent(this.attendance);
}

class LoadSalaryHistory extends EmployeeEvent {
  final String employeeId;
  const LoadSalaryHistory(this.employeeId);
}

class LoadPerformance extends EmployeeEvent {
  final String employeeId;
  final DateTime start;
  final DateTime end;
  const LoadPerformance(this.employeeId, this.start, this.end);
}
