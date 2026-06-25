import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_user.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();
  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserManagementEvent {
  final String tenantId;
  const LoadUsers(this.tenantId);
}

class AddUser extends UserManagementEvent {
  final AppUser user;
  const AddUser(this.user);
}

class UpdateUserRole extends UserManagementEvent {
  final String uid;
  final UserRole role;
  const UpdateUserRole(this.uid, this.role);
}

class DeleteUser extends UserManagementEvent {
  final String uid;
  const DeleteUser(this.uid);
}
