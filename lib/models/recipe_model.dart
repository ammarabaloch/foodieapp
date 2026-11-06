class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String prepTime;
  final String cookTime;
  final int servings;
  final int calories;
  final String difficulty; // "Easy", "Medium", "Hard"
  final List<String> ingredients;
  final List<String> instructions;
  final bool isFavorite;
  final bool isUserCreated;
  final bool isFeatured;
  final bool isHealthy;
  final double rating;
  final int reviewCount;
  final String author;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.calories,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    this.isFavorite = false,
    this.isUserCreated = false,
    this.isFeatured = false,
    this.isHealthy = false,
    this.rating = 4.8,
    this.reviewCount = 56,
    this.author = 'Foodie Chef',
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    String? prepTime,
    String? cookTime,
    int? servings,
    int? calories,
    String? difficulty,
    List<String>? ingredients,
    List<String>? instructions,
    bool? isFavorite,
    bool? isUserCreated,
    bool? isFeatured,
    bool? isHealthy,
    double? rating,
    int? reviewCount,
    String? author,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      isFavorite: isFavorite ?? this.isFavorite,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      isFeatured: isFeatured ?? this.isFeatured,
      isHealthy: isHealthy ?? this.isHealthy,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'calories': calories,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'instructions': instructions,
      'isFavorite': isFavorite,
      'isUserCreated': isUserCreated,
      'isFeatured': isFeatured,
      'isHealthy': isHealthy,
      'rating': rating,
      'reviewCount': reviewCount,
      'author': author,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Recipe',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'Dinner',
      prepTime: json['prepTime'] as String? ?? '15 min',
      cookTime: json['cookTime'] as String? ?? '20 min',
      servings: (json['servings'] as num?)?.toInt() ?? 2,
      calories: (json['calories'] as num?)?.toInt() ?? 350,
      difficulty: json['difficulty'] as String? ?? 'Medium',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      isUserCreated: json['isUserCreated'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isHealthy: json['isHealthy'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 1,
      author: json['author'] as String? ?? 'Foodie Chef',
    );
  }
}
