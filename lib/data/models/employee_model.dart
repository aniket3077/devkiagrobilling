import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/employee.dart';
import 'user_model.dart';

class AttendanceModel extends Attendance {
  const AttendanceModel({
    required super.id,
    required super.employeeId,
    required super.tenantId,
    required super.branchId,
    required super.date,
    super.checkIn,
    super.checkOut,
    required super.status,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      employeeId: map['employeeId'] ?? '',
      tenantId: map['tenantId'] ?? '',
      branchId: map['branchId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      checkIn: map['checkIn'] != null ? (map['checkIn'] as Timestamp).toDate() : null,
      checkOut: map['checkOut'] != null ? (map['checkOut'] as Timestamp).toDate() : null,
      status: map['status'] ?? 'absent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'tenantId': tenantId,
      'branchId': branchId,
      'date': Timestamp.fromDate(date),
      'checkIn': checkIn != null ? Timestamp.fromDate(checkIn!) : null,
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'status': status,
    };
  }
}

class SalaryRecordModel extends SalaryRecord {
  const SalaryRecordModel({
    required super.id,
    required super.employeeId,
    required super.tenantId,
    required super.month,
    required super.amount,
    required super.bonus,
    required super.deductions,
    required super.finalAmount,
    required super.paymentStatus,
    super.paidDate,
  });

  factory SalaryRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return SalaryRecordModel(
      id: id,
      employeeId: map['employeeId'] ?? '',
      tenantId: map['tenantId'] ?? '',
      month: (map['month'] as Timestamp).toDate(),
      amount: (map['amount'] ?? 0.0).toDouble(),
      bonus: (map['bonus'] ?? 0.0).toDouble(),
      deductions: (map['deductions'] ?? 0.0).toDouble(),
      finalAmount: (map['finalAmount'] ?? 0.0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paidDate: map['paidDate'] != null ? (map['paidDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'tenantId': tenantId,
      'month': Timestamp.fromDate(month),
      'amount': amount,
      'bonus': bonus,
      'deductions': deductions,
      'finalAmount': finalAmount,
      'paymentStatus': paymentStatus,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
    };
  }
}
