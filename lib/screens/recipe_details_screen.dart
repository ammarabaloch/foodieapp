import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/recipe_model.dart';
import '../state/recipe_state.dart';
import '../widgets/recipe_image.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  // Track checked ingredients for the interactive cooking checklist
  final Set<int> _checkedIngredients = {};
  int _servingMultiplier = 1;

  @override
  Widget build(BuildContext context) {
    final recipeState = RecipeScope.of(context);
    final recipe = recipeState.getRecipeById(widget.recipeId);

    if (recipe == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Recipe removed'),
        ),
      );
    }

    final isFav = recipe.isFavorite;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= 900;

          if (isLargeScreen) {
            // Tablet / Desktop 2-column layout
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, recipeState, recipe, isFav),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Large Image & Quick Stats
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: RecipeImage(
                                      imageUrl: recipe.imageUrl,
                                      height: 380,
                                      width: double.infinity,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildMetricsCard(recipe),
                                  const SizedBox(height: 20),
                                  _buildChefCard(recipe),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Right Column: Title, Ingredients, Instructions
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeaderInfo(recipe),
                                  const SizedBox(height: 24),
                                  _buildIngredientsSection(recipe),
                                  const SizedBox(height: 28),
                                  _buildInstructionsSection(recipe),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Mobile fluid single-column layout
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, recipeState, recipe, isFav),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderInfo(recipe),
                      const SizedBox(height: 18),
                      _buildMetricsCard(recipe),
                      const SizedBox(height: 20),
                      _buildChefCard(recipe),
                      const SizedBox(height: 28),
                      _buildIngredientsSection(recipe),
                      const SizedBox(height: 28),
                      _buildInstructionsSection(recipe),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    RecipeState recipeState,
    Recipe recipe,
    bool isFav,
  ) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        if (recipe.isUserCreated)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.92),
              child: IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                tooltip: 'Edit Recipe',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditRecipeScreen(recipe: recipe),
                    ),
                  );
                },
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.92),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFav),
                  color: isFav ? AppColors.primary : AppColors.textPrimary,
                  size: 22,
                ),
              ),
              onPressed: () {
                recipeState.toggleFavorite(recipe.id);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 1400),
                    content: Text(
                      isFav
                          ? 'Removed from Favorites'
                          : 'Added to your Favorites ❤️',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'recipe_image_${recipe.id}',
              child: RecipeImage(
                imageUrl: recipe.imageUrl,
                borderRadius: BorderRadius.zero,
              ),
            ),
            // Gradient Overlay for visibility of top buttons
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: recipe.isHealthy
                    ? AppColors.healthyGreenLight
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    recipe.isHealthy ? Icons.eco_rounded : Icons.restaurant_rounded,
                    size: 14,
                    color: recipe.isHealthy
                        ? AppColors.healthyGreenDark
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recipe.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: recipe.isHealthy
                          ? AppColors.healthyGreenDark
                          : AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (recipe.isHealthy)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.healthyGreenLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'HEALTHY CHOICE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.healthyGreenDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          recipe.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          recipe.description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsCard(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            icon: Icons.timer_outlined,
            title: 'Prep Time',
            value: recipe.prepTime,
            color: AppColors.textPrimary,
          ),
          _buildDivider(),
          _buildMetricItem(
            icon: Icons.people_outline_rounded,
            title: 'Servings',
            value: '${recipe.servings * _servingMultiplier}',
            color: AppColors.textPrimary,
          ),
          _buildDivider(),
          _buildMetricItem(
            icon: recipe.isHealthy
                ? Icons.eco_rounded
                : Icons.local_fire_department_rounded,
            title: 'Calories',
            value: '${recipe.calories} kcal',
            color: recipe.isHealthy
                ? AppColors.healthyGreenDark
                : AppColors.primary,
          ),
          _buildDivider(),
          _buildMetricItem(
            icon: Icons.tune_rounded,
            title: 'Difficulty',
            value: recipe.difficulty,
            color: recipe.difficulty == 'Easy'
                ? AppColors.healthyGreenDark
                : AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.borderLight,
    );
  }

  Widget _buildChefCard(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(
              Icons.soup_kitchen_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.author,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Verified Foodie Recipe Creator',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.starRating,
                size: 18,
              ),
              const SizedBox(width: 2),
              Text(
                recipe.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${recipe.reviewCount})',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${recipe.ingredients.length} items',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            // Serving scale adjuster
            Row(
              children: [
                const Text(
                  'Portion:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 6),
                _buildServingScaleButton('1x', 1),
                const SizedBox(width: 4),
                _buildServingScaleButton('2x', 2),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recipe.ingredients.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 48,
              endIndent: 16,
              color: AppColors.borderLight,
            ),
            itemBuilder: (context, index) {
              final ingredient = recipe.ingredients[index];
              final isChecked = _checkedIngredients.contains(index);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _checkedIngredients.remove(index);
                    } else {
                      _checkedIngredients.add(index);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isChecked
                              ? AppColors.healthyGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isChecked
                                ? AppColors.healthyGreen
                                : AppColors.border,
                            width: 1.8,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          ingredient,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isChecked
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServingScaleButton(String label, int multiplier) {
    final isSelected = _servingMultiplier == multiplier;
    return InkWell(
      onTap: () {
        setState(() {
          _servingMultiplier = multiplier;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Cooking Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${recipe.instructions.length} steps',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recipe.instructions.length,
          itemBuilder: (context, index) {
            final step = recipe.instructions[index];
            final stepNumber = index + 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
