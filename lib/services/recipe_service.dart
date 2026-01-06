import '../models/recipe.dart';
import '../models/favorite.dart';
import 'storage_service.dart';

class RecipeService {
  final StorageService _storageService = StorageService();

  Future<List<Recipe>> getAllRecipes() async {
    final recipesJson = await _storageService.getRecipes();
    return recipesJson.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<Recipe?> getRecipeById(String id) async {
    final recipes = await getAllRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addFavorite(String userId, String recipeId) async {
    final favorite = Favorite(
      userId: userId,
      recipeId: recipeId,
      addedAt: DateTime.now(),
    );
    await _storageService.addFavorite(favorite.toJson());
  }

  Future<void> removeFavorite(String userId, String recipeId) async {
    await _storageService.removeFavorite(userId, recipeId);
  }

  Future<List<Recipe>> getUserFavorites(String userId) async {
    final favoriteIds = await _storageService.getUserFavoriteRecipeIds(userId);
    final allRecipes = await getAllRecipes();
    return allRecipes
        .where((recipe) => favoriteIds.contains(recipe.id))
        .toList();
  }

  Future<bool> isFavorite(String userId, String recipeId) async {
    return await _storageService.isFavorite(userId, recipeId);
  }
}

