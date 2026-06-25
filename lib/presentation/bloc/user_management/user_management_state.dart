import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_user.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();
  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UsersLoaded extends UserManagementState {
  final List<AppUser> users;
  const UsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class UserManagementError extends UserManagementState {
  final String message;
  const UserManagementError(this.message);
}
