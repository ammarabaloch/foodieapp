import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFFFF7A59)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.32),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowAccent,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.soup_kitchen_rounded,
              color: Colors.white,
              size: size * 0.58,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Foodie',
                    style: TextStyle(
                      fontSize: size * 0.55,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '.',
                    style: TextStyle(
                      fontSize: size * 0.55,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (showSubtitle)
                Text(
                  'Delicious Everyday Recipes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: size * 0.28,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
