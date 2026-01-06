class Favorite {
  final String userId;
  final String recipeId;
  final DateTime addedAt;

  Favorite({
    required this.userId,
    required this.recipeId,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      userId: json['userId'] as String,
      recipeId: json['recipeId'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

