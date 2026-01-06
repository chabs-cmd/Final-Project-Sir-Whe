import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _usersKey = 'users';
  static const String _recipesKey = 'recipes';
  static const String _favoritesKey = 'favorites';
  static const String _currentUserKey = 'current_user';

  // User operations
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsersAsync();
    users.add(user);
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  // Deprecated: Use getUsersAsync() instead
  // This method is kept for backward compatibility but should not be used
  @Deprecated('Use getUsersAsync() instead')
  List<Map<String, dynamic>> getUsers() {
    return [];
  }

  Future<List<Map<String, dynamic>>> getUsersAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return [];
    final List<dynamic> decoded = jsonDecode(usersJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final users = await getUsersAsync();
    try {
      return users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  Future<void> setCurrentUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Recipe operations
  Future<void> saveRecipes(List<Map<String, dynamic>> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recipesKey, jsonEncode(recipes));
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getString(_recipesKey);
    if (recipesJson == null) return [];
    final List<dynamic> decoded = jsonDecode(recipesJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  // Favorite operations
  Future<void> addFavorite(Map<String, dynamic> favorite) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.add(favorite);
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  Future<void> removeFavorite(String userId, String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((fav) =>
        fav['userId'] == userId && fav['recipeId'] == recipeId);
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];
    final List<dynamic> decoded = jsonDecode(favoritesJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<List<String>> getUserFavoriteRecipeIds(String userId) async {
    final favorites = await getFavorites();
    return favorites
        .where((fav) => fav['userId'] == userId)
        .map((fav) => fav['recipeId'] as String)
        .toList();
  }

  Future<bool> isFavorite(String userId, String recipeId) async {
    final favorites = await getFavorites();
    return favorites.any((fav) =>
        fav['userId'] == userId && fav['recipeId'] == recipeId);
  }
}

