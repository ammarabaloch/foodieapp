import 'package:flutter/material.dart';

/// App color palette matching the Foodie design specification:
/// - Warm cream/off-white background
/// - Orange/coral primary color
/// - Dark charcoal text
/// - Green accent for healthy food
class AppColors {
  AppColors._();

  // Backgrounds & Surfaces (Warm cream / off-white)
  static const Color background = Color(0xFFFBF8F3);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF6F1E8);
  static const Color surfaceWarm = Color(0xFFFDFBF7);
  static const Color border = Color(0xFFEDE5D8);
  static const Color borderLight = Color(0xFFF4EEE5);

  // Primary: Coral / Orange
  static const Color primary = Color(0xFFFF5A36);
  static const Color primaryHover = Color(0xFFE84926);
  static const Color primaryLight = Color(0xFFFFECE5);
  static const Color primarySoft = Color(0xFFFFF2ED);

  // Healthy Accent: Green
  static const Color healthyGreen = Color(0xFF10B981);
  static const Color healthyGreenLight = Color(0xFFE6F7F0);
  static const Color healthyGreenDark = Color(0xFF059669);

  // Text: Dark Charcoal & Neutrals
  static const Color textPrimary = Color(0xFF1F2226);
  static const Color textSecondary = Color(0xFF616773);
  static const Color textMuted = Color(0xFF959BA5);
  static const Color textLight = Color(0xFFB5BAC1);

  // Accent & Status
  static const Color starRating = Color(0xFFFFB020);
  static const Color starRatingBg = Color(0xFFFFF8E7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoBlueLight = Color(0xFFEFF6FF);

  // Shadows
  static const Color shadowColor = Color(0x0F000000);
  static const Color shadowAccent = Color(0x1AFF5A36);
}

