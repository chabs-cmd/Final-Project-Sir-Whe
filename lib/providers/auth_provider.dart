import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _authService.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.register(email, password, name);
    if (success) {
      _currentUser = await _authService.getCurrentUser();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _authService.login(email, password);
    final success = _currentUser != null;

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}

