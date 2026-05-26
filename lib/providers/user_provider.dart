import 'package:flutter/foundation.dart';
import 'package:musicman/models/user_model.dart';
import 'package:musicman/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _users = [];
  bool _isLoading = false;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    _users = await _userService.getAllUsers();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteUser(String uid) async {
    await _userService.deleteUser(uid);
    _users.removeWhere((u) => u.uid == uid);
    notifyListeners();
  }

  Future<void> toggleAdmin(String uid, bool isAdmin) async {
    await _userService.toggleAdminRole(uid, isAdmin);

    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      final user = _users[index];
      _users[index] = UserModel(
        uid: user.uid,
        email: user.email,
        name: user.name,
        phone: user.phone,
        role: isAdmin ? 'admin' : 'client',
        createdAt: user.createdAt,
        isActive: user.isActive,
      );
      notifyListeners();
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _userService.updateUser(uid, data);

    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      _users[index] = UserModel.fromMap(
        {..._users[index].toMap(), ...data},
        uid,
      );
      notifyListeners();
    }
  }
}
