import 'package:equatable/equatable.dart';

enum UserRole { admin, shopkeeper }

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String tenantId;
  final String? branchId; // Null for global owners
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    required this.tenantId,
    this.branchId,
    this.role = UserRole.shopkeeper,
  });

  @override
  List<Object?> get props => [uid, email, displayName, phoneNumber, tenantId, branchId, role];
}
