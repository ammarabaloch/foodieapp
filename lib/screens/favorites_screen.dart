import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../state/recipe_state.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/recipe_card_standard.dart';
import 'main_navigation_screen.dart';
import 'recipe_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeState = RecipeScope.of(context);
    final favorites = recipeState.favoriteRecipes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Favorites'),
        actions: [
          if (favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${favorites.length} saved',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'No Favorites Yet',
              message:
                  'You haven\'t added any recipes to your favorites. Tap the heart icon on any recipe to save it for quick access here!',
              buttonText: 'Explore Recipes',
              onButtonPressed: () {
                MainNavigationScreen.switchTab(context, 0);
              },
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Text(
                      'Your personal culinary collection',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
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
                          childAspectRatio: 0.65,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final recipe = favorites[index];
                            return RecipeCardStandard(
                              recipe: recipe,
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
                            );
                          },
                          childCount: favorites.length,
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 36)),
              ],
            ),
    );
  }
}
