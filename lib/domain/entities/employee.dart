import 'package:equatable/equatable.dart';
import 'app_user.dart';

class Employee extends Equatable {
  final AppUser user;
  final DateTime dateOfJoining;
  final double baseSalary;
  final String department;
  final bool isActive;

  const Employee({
    required this.user,
    required this.dateOfJoining,
    required this.baseSalary,
    required this.department,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [user, dateOfJoining, baseSalary, department, isActive];
}

class Attendance extends Equatable {
  final String id;
  final String employeeId;
  final String tenantId;
  final String branchId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status; // 'present', 'absent', 'late', 'half_day'

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.tenantId,
    required this.branchId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
  });

  @override
  List<Object?> get props => [id, employeeId, tenantId, branchId, date, checkIn, checkOut, status];
}

class SalaryRecord extends Equatable {
  final String id;
  final String employeeId;
  final String tenantId;
  final DateTime month;
  final double amount;
  final double bonus;
  final double deductions;
  final double finalAmount;
  final String paymentStatus; // 'paid', 'pending'
  final DateTime? paidDate;

  const SalaryRecord({
    required this.id,
    required this.employeeId,
    required this.tenantId,
    required this.month,
    required this.amount,
    required this.bonus,
    required this.deductions,
    required this.finalAmount,
    required this.paymentStatus,
    this.paidDate,
  });

  @override
  List<Object?> get props => [id, employeeId, tenantId, month, amount, bonus, deductions, finalAmount, paymentStatus, paidDate];
}
