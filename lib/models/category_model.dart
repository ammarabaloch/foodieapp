import 'package:flutter/material.dart';

class RecipeCategory {
  final String id;
  final String name;
  final IconData icon;
  final bool isHealthy;

  const RecipeCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.isHealthy = false,
  });

  static List<RecipeCategory> defaultCategories() {
    return const [
      RecipeCategory(id: 'all', name: 'All Recipes', icon: Icons.restaurant_menu_rounded),
      RecipeCategory(id: 'my_food', name: 'My Food', icon: Icons.lunch_dining_rounded),
      RecipeCategory(id: 'breakfast', name: 'Breakfast', icon: Icons.free_breakfast_rounded),
      RecipeCategory(id: 'healthy', name: 'Healthy', icon: Icons.eco_rounded, isHealthy: true),
      RecipeCategory(id: 'lunch', name: 'Lunch', icon: Icons.local_dining_rounded),
      RecipeCategory(id: 'dinner', name: 'Dinner', icon: Icons.dinner_dining_rounded),
      RecipeCategory(id: 'italian', name: 'Italian', icon: Icons.local_pizza_rounded),
      RecipeCategory(id: 'asian', name: 'Asian', icon: Icons.ramen_dining_rounded),
      RecipeCategory(id: 'mexican', name: 'Mexican', icon: Icons.fastfood_rounded),
      RecipeCategory(id: 'desserts', name: 'Desserts', icon: Icons.cake_rounded),
      RecipeCategory(id: 'beverages', name: 'Beverages', icon: Icons.local_cafe_rounded),
      RecipeCategory(id: 'salads', name: 'Salads', icon: Icons.grass_rounded, isHealthy: true),
      RecipeCategory(id: 'vegan', name: 'Vegan', icon: Icons.spa_rounded, isHealthy: true),
    ];
  }
}
