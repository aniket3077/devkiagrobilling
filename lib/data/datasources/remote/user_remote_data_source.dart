import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../../domain/entities/app_user.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers(String tenantId);
  Future<UserModel> getUserById(String uid);
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String uid);
  Future<void> updateRole(String uid, UserRole newRole);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<UserModel>> getAllUsers(String tenantId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('tenantId', isEqualTo: tenantId)
        .get();
    return querySnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<UserModel> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    return UserModel.fromMap(doc.data()!);
  }

  @override
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  @override
  Future<void> updateRole(String uid, UserRole newRole) async {
    await _firestore.collection('users').doc(uid).update({'role': newRole.name});
  }
}
