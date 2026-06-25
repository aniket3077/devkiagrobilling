import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/user_repository.dart';
import 'user_management_event.dart';
import 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final UserRepository userRepository;

  UserManagementBloc({required this.userRepository})
      : super(UserManagementInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<AddUser>(_onAddUser);
    on<UpdateUserRole>(_onUpdateUserRole);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserManagementState> emit) async {
    emit(UserManagementLoading());
    final result = await userRepository.getAllUsers(event.tenantId);
    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }

  Future<void> _onAddUser(AddUser event, Emitter<UserManagementState> emit) async {
    final result = await userRepository.createUser(event.user);
    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (_) => add(LoadUsers('temp_tenant_id')), // Refresh
    );
  }

  Future<void> _onUpdateUserRole(UpdateUserRole event, Emitter<UserManagementState> emit) async {
    final result = await userRepository.updateRole(event.uid, event.role);
    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (_) => add(LoadUsers('temp_tenant_id')), // Refresh
    );
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserManagementState> emit) async {
    final result = await userRepository.deleteUser(event.uid);
    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (_) => add(LoadUsers('temp_tenant_id')), // Refresh
    );
  }
}
