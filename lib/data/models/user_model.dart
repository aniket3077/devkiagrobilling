import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.email,
    required super.tenantId,
    super.branchId,
    super.displayName,
    super.phoneNumber,
    super.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      tenantId: map['tenantId'] ?? '',
      branchId: map['branchId'],
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'shopkeeper') || (map['role'] == 'staff' && e == UserRole.shopkeeper),
        orElse: () => UserRole.shopkeeper,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'tenantId': tenantId,
      'branchId': branchId,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role.name,
    };
  }
}
