import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/favorite_button.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isImageLoading = true;
  Object? _imageError;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _imageError = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        final isFav = await recipeProvider.isFavorite(widget.recipeId);
        if (mounted) {
          setState(() => _isFavorite = isFav);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load favorite status: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Optimistic update
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      await recipeProvider.toggleFavorite(widget.recipeId);
      // Refresh favorite status to ensure consistency
      final isFav = await recipeProvider.isFavorite(widget.recipeId);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildRecipeImage(String imageUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_imageError != null)
          Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 100),
          )
        else
          Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300,
            errorBuilder: (context, error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isImageLoading = false;
                    _imageError = error;
                  });
                }
              });
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 100),
              );
            },
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame == null) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _isImageLoading = false);
                }
              });
              return child;
            },
          ),
        if (_isImageLoading)
          const Positioned(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final recipe = recipeProvider.getRecipeById(widget.recipeId);

        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe Not Found')),
            body: const Center(child: Text('Recipe not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: recipe.image.isNotEmpty
                      ? _buildRecipeImage(recipe.image)
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                actions: [
                  if (!_isLoading)
                    FavoriteButton(
                      isFavorite: _isFavorite,
                      onPressed: _toggleFavorite,
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildInfoChip(
                              icon: Icons.access_time,
                              text: '${recipe.cookingTime} min',
                            ),
                            const SizedBox(width: 12),
                            _buildInfoChip(
                              icon: Icons.people,
                              text: '${recipe.servings} ${recipe.servings > 1 ? 'servings' : 'serving'}',
                            ),
                            const SizedBox(width: 12),
                            _buildCategoryChip(recipe.category),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Ingredients'),
                      const SizedBox(height: 12),
                      ...recipe.ingredients.map((ingredient) => _buildListItem(ingredient)),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Instructions'),
                      const SizedBox(height: 12),
                      ...recipe.instructions.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        return _buildNumberedListItem(index, entry.value);
                      }),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: Colors.orange[800],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedListItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}