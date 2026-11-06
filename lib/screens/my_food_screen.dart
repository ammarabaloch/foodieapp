import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/recipe_model.dart';
import '../state/recipe_state.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/recipe_card_standard.dart';
import 'add_recipe_screen.dart';
import 'edit_recipe_screen.dart';
import 'recipe_details_screen.dart';

class MyFoodScreen extends StatelessWidget {
  const MyFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeState = RecipeScope.of(context);
    final myRecipes = recipeState.userRecipes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Food'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddRecipeScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Recipe'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddRecipeScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Recipe',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: myRecipes.isEmpty
          ? EmptyStateView(
              icon: Icons.soup_kitchen_outlined,
              title: 'No Custom Recipes Yet',
              message:
                  'Share your culinary creations! Create your first custom recipe with ingredients, instructions, and photography.',
              buttonText: 'Add New Recipe',
              onButtonPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddRecipeScreen(),
                  ),
                );
              },
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Recipes (${myRecipes.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Recipes created by you',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      final crossAxisCount = width > 900
                          ? 4
                          : width > 600
                              ? 3
                              : 2;

                      return SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.58,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final recipe = myRecipes[index];
                            return RecipeCardStandard(
                              recipe: recipe,
                              showManageActions: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecipeDetailsScreen(
                                      recipeId: recipe.id,
                                    ),
                                  ),
                                );
                              },
                              onFavoriteToggle: () {
                                recipeState.toggleFavorite(recipe.id);
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditRecipeScreen(
                                      recipe: recipe,
                                    ),
                                  ),
                                );
                              },
                              onDelete: () {
                                _confirmDelete(context, recipeState, recipe);
                              },
                            );
                          },
                          childCount: myRecipes.length,
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
    );
  }

  void _confirmDelete(BuildContext context, RecipeState state, Recipe recipe) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Recipe?'),
          content: Text(
            'Are you sure you want to remove "${recipe.title}"? This action cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                state.deleteRecipe(recipe.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${recipe.title}"'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
