import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<AppUser>>> getAllUsers(String tenantId) async {
    try {
      final users = await remoteDataSource.getAllUsers(tenantId);
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> getUserById(String uid) async {
    try {
      final user = await remoteDataSource.getUserById(uid);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createUser(AppUser user) async {
    try {
      await remoteDataSource.createUser(_toModel(user));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUser(AppUser user) async {
    try {
      await remoteDataSource.updateUser(_toModel(user));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String uid) async {
    try {
      await remoteDataSource.deleteUser(uid);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateRole(String uid, UserRole newRole) async {
    try {
      await remoteDataSource.updateRole(uid, newRole);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  UserModel _toModel(AppUser user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      tenantId: user.tenantId,
      branchId: user.branchId,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      role: user.role,
    );
  }
}
