import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RecipeBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final bool isSmall;

  const RecipeBadge({
    super.key,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.isSmall = false,
  });

  factory RecipeBadge.difficulty(String difficulty, {bool isSmall = false}) {
    Color bg;
    Color fg;
    IconData icon;

    switch (difficulty.toLowerCase()) {
      case 'easy':
        bg = AppColors.healthyGreenLight;
        fg = AppColors.healthyGreenDark;
        icon = Icons.spa_rounded;
        break;
      case 'medium':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        icon = Icons.bolt_rounded;
        break;
      case 'hard':
        bg = AppColors.dangerLight;
        fg = AppColors.danger;
        icon = Icons.local_fire_department_rounded;
        break;
      default:
        bg = AppColors.surfaceMuted;
        fg = AppColors.textSecondary;
        icon = Icons.tune_rounded;
    }

    return RecipeBadge(
      icon: icon,
      label: difficulty,
      backgroundColor: bg,
      textColor: fg,
      iconColor: fg,
      isSmall: isSmall,
    );
  }

  factory RecipeBadge.calories(int calories, {bool isSmall = false, bool isHealthy = false}) {
    return RecipeBadge(
      icon: isHealthy ? Icons.eco_rounded : Icons.local_fire_department_rounded,
      label: '$calories kcal',
      backgroundColor: isHealthy ? AppColors.healthyGreenLight : const Color(0xFFFFF4EC),
      textColor: isHealthy ? AppColors.healthyGreenDark : AppColors.primary,
      iconColor: isHealthy ? AppColors.healthyGreen : AppColors.primary,
      isSmall: isSmall,
    );
  }

  factory RecipeBadge.time(String time, {bool isSmall = false}) {
    return RecipeBadge(
      icon: Icons.timer_outlined,
      label: time,
      backgroundColor: AppColors.surfaceMuted,
      textColor: AppColors.textSecondary,
      iconColor: AppColors.textSecondary,
      isSmall: isSmall,
    );
  }

  factory RecipeBadge.servings(int servings, {bool isSmall = false}) {
    return RecipeBadge(
      icon: Icons.people_outline_rounded,
      label: '$servings servings',
      backgroundColor: AppColors.surfaceMuted,
      textColor: AppColors.textSecondary,
      iconColor: AppColors.textSecondary,
      isSmall: isSmall,
    );
  }

  factory RecipeBadge.rating(double rating, {bool isSmall = false}) {
    return RecipeBadge(
      icon: Icons.star_rounded,
      label: rating.toStringAsFixed(1),
      backgroundColor: AppColors.starRatingBg,
      textColor: const Color(0xFFB45309),
      iconColor: AppColors.starRating,
      isSmall: isSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isSmall ? 13 : 15,
            color: iconColor ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: textColor ?? AppColors.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

