import 'package:fpdart/fpdart.dart';
import '../entities/employee.dart';
import '../../core/error/failures.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, List<Attendance>>> getAttendance(String tenantId, String branchId, DateTime date);
  Future<Either<Failure, Unit>> markAttendance(Attendance attendance);
  
  Future<Either<Failure, List<SalaryRecord>>> getSalaryHistory(String employeeId);
  Future<Either<Failure, Unit>> generateSalary(SalaryRecord record);
  
  Future<Either<Failure, Map<String, dynamic>>> getEmployeePerformance(String employeeId, DateTime start, DateTime end);
}
