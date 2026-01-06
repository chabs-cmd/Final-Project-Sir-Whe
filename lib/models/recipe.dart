import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String image;
  final int cookingTime; // in minutes
  final int servings;
  final String category;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.image,
    required this.cookingTime,
    required this.servings,
    required this.category,
  })  : assert(id != '', 'Recipe ID cannot be empty'),
        assert(name != '', 'Recipe name cannot be empty'),
        assert(description != '', 'Description cannot be empty'),
        assert(cookingTime > 0, 'Cooking time must be greater than 0'),
        assert(servings > 0, 'Servings must be greater than 0'),
        assert(category != '', 'Category cannot be empty');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'image': image,
      'cookingTime': cookingTime,
      'servings': servings,
      'category': category,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    try {
      return Recipe(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Unnamed Recipe',
        description: json['description'] as String? ?? 'No description provided',
        ingredients: (json['ingredients'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        instructions: (json['instructions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        image: json['image'] as String? ?? '',
        cookingTime: (json['cookingTime'] as num?)?.toInt() ?? 30,
        servings: (json['servings'] as num?)?.toInt() ?? 1,
        category: json['category'] as String? ?? 'Uncategorized',
      );
    } catch (e) {
      throw FormatException('Failed to parse Recipe: $e');
    }
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    String? image,
    int? cookingTime,
    int? servings,
    String? category,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? List.from(this.ingredients),
      instructions: instructions ?? List.from(this.instructions),
      image: image ?? this.image,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          listEquals(ingredients, other.ingredients) &&
          listEquals(instructions, other.instructions) &&
          image == other.image &&
          cookingTime == other.cookingTime &&
          servings == other.servings &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      ingredients.hashCode ^
      instructions.hashCode ^
      image.hashCode ^
      cookingTime.hashCode ^
      servings.hashCode ^
      category.hashCode;

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, category: $category, '
        'cookingTime: $cookingTime min, servings: $servings)';
  }
}