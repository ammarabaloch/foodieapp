import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/category_model.dart';

class CategoryChipWidget extends StatelessWidget {
  final RecipeCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChipWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = category.isHealthy ? AppColors.healthyGreen : AppColors.primary;
    final activeShadow = category.isHealthy
        ? const Color(0x3310B981)
        : AppColors.shadowAccent;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? activeBg : AppColors.cardSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected
                    ? activeBg
                    : (category.isHealthy
                        ? AppColors.healthyGreen.withValues(alpha: 0.3)
                        : AppColors.border),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeShadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      const BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (category.isHealthy
                          ? AppColors.healthyGreen
                          : AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
                if (category.isHealthy && !isSelected) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.healthyGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
