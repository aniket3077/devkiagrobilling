import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final String? uid;
  const AuthUserChanged(this.uid);
}

class AuthLogoutRequested extends AuthEvent {}
