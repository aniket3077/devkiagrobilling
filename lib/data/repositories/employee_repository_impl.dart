import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final FirebaseFirestore _firestore;

  EmployeeRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<Attendance>>> getAttendance(String tenantId, String branchId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('attendance')
          .where('tenantId', isEqualTo: tenantId)
          .where('branchId', isEqualTo: branchId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return Right(snapshot.docs.map((doc) => AttendanceModel.fromMap(doc.data(), doc.id)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAttendance(Attendance attendance) async {
    try {
      final model = AttendanceModel(
        id: attendance.id,
        employeeId: attendance.employeeId,
        tenantId: attendance.tenantId,
        branchId: attendance.branchId,
        date: attendance.date,
        checkIn: attendance.checkIn,
        checkOut: attendance.checkOut,
        status: attendance.status,
      );
      
      await _firestore.collection('attendance').doc(model.id.isEmpty ? null : model.id).set(model.toMap(), SetOptions(merge: true));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalaryRecord>>> getSalaryHistory(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection('salaries')
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('month', descending: true)
          .get();

      return Right(snapshot.docs.map((doc) => SalaryRecordModel.fromMap(doc.data(), doc.id)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> generateSalary(SalaryRecord record) async {
    try {
      final model = SalaryRecordModel(
        id: record.id,
        employeeId: record.employeeId,
        tenantId: record.tenantId,
        month: record.month,
        amount: record.amount,
        bonus: record.bonus,
        deductions: record.deductions,
        finalAmount: record.finalAmount,
        paymentStatus: record.paymentStatus,
        paidDate: record.paidDate,
      );
      await _firestore.collection('salaries').add(model.toMap());
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getEmployeePerformance(String employeeId, DateTime start, DateTime end) async {
    try {
      // Performance based on total sales processed by this employee
      final snapshot = await _firestore
          .collection('invoices')
          .where('staffId', isEqualTo: employeeId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      double totalSales = 0;
      for (var doc in snapshot.docs) {
        totalSales += (doc.data()['grandTotal'] ?? 0.0).toDouble();
      }

      return Right({
        'totalSales': totalSales,
        'orderCount': snapshot.docs.length,
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
