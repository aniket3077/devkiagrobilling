import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;

  const AuthState._({
    required this.status,
    this.user,
  });

  const AuthState.authenticated(AppUser user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

  const AuthState.loading() : this._(status: AuthStatus.loading);

  @override
  List<Object?> get props => [status, user];
}
