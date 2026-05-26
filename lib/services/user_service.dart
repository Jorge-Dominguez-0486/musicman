import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musicman/core/constants/app_constants.dart';
import 'package:musicman/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error en createUser: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error en getUser: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update(data);
    } catch (e) {
      print('Error en updateUser: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();
    } catch (e) {
      print('Error en deleteUser: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.usersCollection).get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error en getAllUsers: $e');
      return [];
    }
  }

  Future<void> toggleAdminRole(String uid, bool isAdmin) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
        'role': isAdmin ? AppConstants.adminRole : AppConstants.clientRole,
      });
    } catch (e) {
      print('Error en toggleAdminRole: $e');
    }
  }
}
