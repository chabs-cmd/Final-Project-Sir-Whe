import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/storage_service.dart';
import '../data/recipes_data.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  final StorageService _storageService = StorageService();
  List<Recipe> _recipes = [];
  List<Recipe> _favorites = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  List<Recipe> get recipes => _recipes;
  List<Recipe> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RecipeProvider() {
    _initializeRecipes();
  }

  Future<void> _initializeRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Always get the latest default recipes to ensure image paths are up to date
      final defaultRecipes = getDefaultRecipes();
      final storedRecipes = await _recipeService.getAllRecipes();

      debugPrint('=== Recipe Provider Initialization ===');
      debugPrint('Default recipes count: ${defaultRecipes.length}');
      debugPrint('Stored recipes count: ${storedRecipes.length}');

      // Log default recipe image paths
      for (var recipe in defaultRecipes) {
        debugPrint('Default Recipe [${recipe.id}] ${recipe.name}: image = "${recipe.image}"');
      }

      if (storedRecipes.isEmpty) {
        debugPrint('No stored recipes found. Initializing with defaults.');
        // Initialize with default recipes
        await _saveRecipes(defaultRecipes);
        _recipes = defaultRecipes;
        debugPrint('Saved ${defaultRecipes.length} default recipes to storage.');
      } else {
        debugPrint('Stored recipes found. Updating with latest defaults...');

        // Log stored recipe image paths before update
        for (var recipe in storedRecipes) {
          debugPrint('Stored Recipe [${recipe.id}] ${recipe.name}: image = "${recipe.image}"');
        }

        // Update stored recipes with latest default recipes (to get new image paths)
        // Create a map of default recipes by ID for quick lookup
        final defaultRecipesMap = {
          for (var recipe in defaultRecipes) recipe.id: recipe
        };

        // Update existing stored recipes with defaults, preserving any custom data
        final updatedRecipes = storedRecipes.map((stored) {
          // If default recipe exists, use it (this ensures image paths are updated)
          if (defaultRecipesMap.containsKey(stored.id)) {
            final defaultRecipe = defaultRecipesMap[stored.id]!;
            if (stored.image != defaultRecipe.image) {
              debugPrint('Updating recipe [${stored.id}] ${stored.name}:');
              debugPrint('  Old image: "${stored.image}"');
              debugPrint('  New image: "${defaultRecipe.image}"');
            }
            return defaultRecipe;
          }
          // Keep stored recipe if no default exists
          return stored;
        }).toList();

        // Add any new recipes from defaults that don't exist in storage
        for (final defaultRecipe in defaultRecipes) {
          if (!updatedRecipes.any((r) => r.id == defaultRecipe.id)) {
            debugPrint('Adding new recipe [${defaultRecipe.id}] ${defaultRecipe.name}');
            updatedRecipes.add(defaultRecipe);
          }
        }

        // Save updated recipes and use them
        await _saveRecipes(updatedRecipes);
        _recipes = updatedRecipes;

        debugPrint('Updated ${updatedRecipes.length} recipes in storage.');
      }

      // Log final recipe image paths
      debugPrint('=== Final Recipe Image Paths ===');
      for (var recipe in _recipes) {
        debugPrint('Recipe [${recipe.id}] ${recipe.name}: image = "${recipe.image}"');
      }
      debugPrint('=== End Recipe Provider Initialization ===');

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error initializing recipes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch recipes (refresh from storage)
  Future<void> fetchRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final storedRecipes = await _recipeService.getAllRecipes();
      
      if (storedRecipes.isNotEmpty) {
        _recipes = storedRecipes;
        _error = null;
      } else {
        // If no stored recipes, reinitialize with defaults
        final defaultRecipes = getDefaultRecipes();
        await _saveRecipes(defaultRecipes);
        _recipes = defaultRecipes;
      }
    } catch (e) {
      _error = 'Failed to load recipes: ${e.toString()}';
      debugPrint('Error fetching recipes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveRecipes(List<Recipe> recipes) async {
    final recipesJson = recipes.map((r) => r.toJson()).toList();
    await _storageService.saveRecipes(recipesJson);
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_currentUserId == null) return;

    try {
      final userId = _currentUserId!;
      _favorites = await _recipeService.getUserFavorites(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    if (_currentUserId == null) return;

    try {
      final isFavorite = await _recipeService.isFavorite(_currentUserId!, recipeId);
      if (isFavorite) {
        await _recipeService.removeFavorite(_currentUserId!, recipeId);
      } else {
        await _recipeService.addFavorite(_currentUserId!, recipeId);
      }

      await _loadFavorites();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<bool> isFavorite(String recipeId) async {
    if (_currentUserId == null) return false;
    try {
      return await _recipeService.isFavorite(_currentUserId!, recipeId);
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}