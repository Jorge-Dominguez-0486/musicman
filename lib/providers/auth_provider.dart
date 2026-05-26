import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musicman/core/constants/app_constants.dart';
import 'package:musicman/models/user_model.dart';
import 'package:musicman/services/auth_service.dart';
import 'package:musicman/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == AppConstants.adminRole;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser != null) {
      _loadUser(firebaseUser.uid);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> _loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _userService.getUser(uid);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signIn(email, password);
      if (credential?.user != null) {
        await _loadUser(credential!.user!.uid);
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error de conexión. Intenta de nuevo.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUp(email, password);
      if (credential?.user != null) {
        final user = UserModel(
          uid: credential!.user!.uid,
          email: email,
          name: name,
          phone: phone,
          role: AppConstants.clientRole,
          createdAt: DateTime.now(),
          isActive: true,
        );
        await _userService.createUser(user);
        _currentUser = user;
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error de conexión. Intenta de nuevo.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'Error al iniciar sesión. Verifica tus credenciales.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkAuthState() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      await _loadUser(firebaseUser.uid);
    }
  }
}
