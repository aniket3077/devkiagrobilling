import 'package:fpdart/fpdart.dart';
import '../entities/app_user.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, Unit>> sendOtp({required String phoneNumber});

  Future<Either<Failure, AppUser>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<Either<Failure, Unit>> resetPassword({required String email});

  Future<void> signOut();

  Stream<AppUser?> get user;
}
