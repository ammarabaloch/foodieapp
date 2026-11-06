import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/category_model.dart';
import '../state/recipe_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/category_chip.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/recipe_card_featured.dart';
import '../widgets/recipe_card_standard.dart';
import '../widgets/search_bar_widget.dart';
import 'add_recipe_screen.dart';
import 'recipe_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeState = RecipeScope.of(context);
    final categories = RecipeCategory.defaultCategories();
    final isSearching = recipeState.searchQuery.isNotEmpty ||
        recipeState.selectedCategoryId != 'all';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar / Brand Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(child: AppLogo(size: 38)),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        // Quick Add Recipe Shortcut button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddRecipeScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Create',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Profile Avatar
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Welcome Heading
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What would you like to cook today?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Explore over 1,000+ curated premium gourmet recipes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: SearchBarWidget(
                  query: recipeState.searchQuery,
                  onChanged: (q) => recipeState.setSearchQuery(q),
                  onFilterTap: () {
                    _showFilterBottomSheet(context, recipeState);
                  },
                ),
              ),
            ),

            // 10+ Horizontally Scrollable Categories
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (recipeState.selectedCategoryId != 'all')
                          TextButton(
                            onPressed: () => recipeState.setSelectedCategory('all'),
                            child: const Text('Reset'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categories.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected =
                            recipeState.selectedCategoryId == cat.id;
                        return CategoryChipWidget(
                          category: cat,
                          isSelected: isSelected,
                          onTap: () => recipeState.setSelectedCategory(cat.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // If user is searching or has applied a category filter, show filtered results
            if (isSearching) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          recipeState.searchQuery.isNotEmpty
                              ? 'Search Results (${recipeState.filteredRecipes.length})'
                              : '${categories.firstWhere((c) => c.id == recipeState.selectedCategoryId, orElse: () => const RecipeCategory(id: 'all', name: 'Recipes', icon: Icons.restaurant_rounded)).name} (${recipeState.filteredRecipes.length})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => recipeState.clearFilters(),
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (recipeState.filteredRecipes.isEmpty)
                SliverToBoxAdapter(
                  child: recipeState.selectedCategoryId == 'my_food'
                      ? EmptyStateView(
                          icon: Icons.soup_kitchen_outlined,
                          title: 'No Recipes in My Food',
                          message:
                              'You haven\'t created any recipes in My Food yet. Create your first culinary masterpiece!',
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
                      : EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'No Recipes Found',
                          message: recipeState.searchQuery.isNotEmpty
                              ? 'We couldn\'t find any recipes matching "${recipeState.searchQuery}". Try a different keyword or category.'
                              : 'No recipes found for this category right now.',
                          buttonText: 'View All Recipes',
                          onButtonPressed: () => recipeState.clearFilters(),
                        ),
                )
              else
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
                            final recipe = recipeState.filteredRecipes[index];
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
                          childCount: recipeState.filteredRecipes.length,
                        ),
                      );
                    },
                  ),
                ),
            ] else ...[
              // Featured Recipes Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Recipes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            'Chef specials',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 325,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: recipeState.featuredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipeState.featuredRecipes[index];
                          return RecipeCardFeatured(
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
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // Popular Recipes Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Popular Recipes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        '${recipeState.popularRecipes.length} recipes',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Responsive Grid of Popular Recipes
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
                          final recipe = recipeState.popularRecipes[index];
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
                        childCount: recipeState.popularRecipes.length,
                      ),
                    );
                  },
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, RecipeState recipeState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Recipes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Dietary Preference',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.eco_rounded, size: 16, color: AppColors.healthyGreen),
                    label: const Text('Healthy Food (Under 400 kcal)'),
                    backgroundColor: AppColors.healthyGreenLight,
                    onPressed: () {
                      recipeState.setSelectedCategory('healthy');
                      Navigator.pop(ctx);
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.star_rounded, size: 16, color: AppColors.starRating),
                    label: const Text('Top Rated (4.9+)'),
                    backgroundColor: AppColors.surfaceMuted,
                    onPressed: () {
                      recipeState.setSearchQuery('Chef');
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
