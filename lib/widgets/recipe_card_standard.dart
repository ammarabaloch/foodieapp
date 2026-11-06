import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/recipe_model.dart';
import 'recipe_badge.dart';
import 'recipe_image.dart';

class RecipeCardStandard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool showManageActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RecipeCardStandard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavoriteToggle,
    this.showManageActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image section with top buttons
                Stack(
                  children: [
                    Hero(
                      tag: 'recipe_image_${recipe.id}',
                      child: RecipeImage(
                        imageUrl: recipe.imageUrl,
                        height: 125,
                        width: double.infinity,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    ),
                    // Category pill
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: recipe.isHealthy
                              ? AppColors.healthyGreen
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          recipe.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: onFavoriteToggle,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: recipe.isFavorite
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              recipe.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 16,
                              color: recipe.isFavorite
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Meta pills
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          RecipeBadge.time(recipe.prepTime, isSmall: true),
                          RecipeBadge.calories(
                            recipe.calories,
                            isSmall: true,
                            isHealthy: recipe.isHealthy,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RecipeBadge.difficulty(
                            recipe.difficulty,
                            isSmall: true,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppColors.starRating,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                recipe.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Manage buttons for My Food screen
                      if (showManageActions) ...[
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit_outlined, size: 14),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primaryLight,
                                  ),
                                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.5),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                              ),
                              color: AppColors.danger,
                              tooltip: 'Delete recipe',
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.dangerLight,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
