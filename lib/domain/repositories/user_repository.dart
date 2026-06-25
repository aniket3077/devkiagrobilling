import 'package:fpdart/fpdart.dart';
import '../entities/app_user.dart';
import '../../core/error/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, List<AppUser>>> getAllUsers(String tenantId);
  Future<Either<Failure, AppUser>> getUserById(String uid);
  Future<Either<Failure, Unit>> createUser(AppUser user);
  Future<Either<Failure, Unit>> updateUser(AppUser user);
  Future<Either<Failure, Unit>> deleteUser(String uid);
  Future<Either<Failure, Unit>> updateRole(String uid, UserRole newRole);
}
