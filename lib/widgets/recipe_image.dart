import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RecipeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    if (imageUrl.trim().isEmpty) {
      return _buildFallback(radius);
    }

    final isLocalFile = !kIsWeb &&
        !imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://') &&
        !imageUrl.startsWith('assets/');

    if (isLocalFile) {
      try {
        final file = File(imageUrl);
        return ClipRRect(
          borderRadius: radius,
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildFallback(radius),
          ),
        );
      } catch (_) {
        return _buildFallback(radius);
      }
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceMuted,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(radius),
      ),
    );
  }

  Widget _buildFallback(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: radius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_rounded,
            size: (height != null && height! < 100) ? 24 : 36,
            color: AppColors.textMuted,
          ),
          if (height == null || height! >= 100) ...[
            const SizedBox(height: 6),
            const Text(
              'Foodie Recipe',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
