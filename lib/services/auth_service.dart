import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storageService = StorageService();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register(String email, String password, String name) async {
    // Check if user already exists
    final existingUser = await _storageService.getUserByEmail(email);
    if (existingUser != null) {
      return false; // User already exists
    }

    // Create new user
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    // Save user with hashed password
    final userMap = user.toJson();
    userMap['password'] = _hashPassword(password);
    await _storageService.saveUser(userMap);

    // Set as current user
    await _storageService.setCurrentUser(user.id);

    return true;
  }

  Future<User?> login(String email, String password) async {
    final userMap = await _storageService.getUserByEmail(email);
    if (userMap == null) {
      return null; // User not found
    }

    final hashedPassword = _hashPassword(password);
    if (userMap['password'] != hashedPassword) {
      return null; // Wrong password
    }

    final user = User.fromJson(userMap);
    await _storageService.setCurrentUser(user.id);
    return user;
  }

  Future<void> logout() async {
    await _storageService.clearCurrentUser();
  }

  Future<User?> getCurrentUser() async {
    final userId = await _storageService.getCurrentUserId();
    if (userId == null) return null;

    final users = await _storageService.getUsersAsync();
    try {
      final userMap = users.firstWhere((user) => user['id'] == userId);
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }
}

