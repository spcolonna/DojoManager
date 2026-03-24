import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tipografías de Grand Dojo.
/// CinzelDecorative → títulos, nombres, UI de honor
/// Rajdhani → stats, números, UI de combate
/// El body text usa Rajdhani también por ser legible y tener caracter marcial.
class AppTextStyles {
  AppTextStyles._();

  // ─── DISPLAY / TÍTULOS GRANDES ─────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'CinzelDecorative',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.goldPrimary,
    letterSpacing: 2.0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'CinzelDecorative',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'CinzelDecorative',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  // ─── HEADINGS ──────────────────────────────────────────────────────────────
  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  // ─── BODY ──────────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  // ─── STATS / NÚMEROS ───────────────────────────────────────────────────────
  static const TextStyle statLarge = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.goldPrimary,
  );

  static const TextStyle statMedium = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle statSmall = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.0,
  );

  // ─── BOTONES ───────────────────────────────────────────────────────────────
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.bgDeep,
    letterSpacing: 1.0,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.goldPrimary,
    letterSpacing: 0.8,
  );

  // ─── LABELS / TAGS ─────────────────────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  static const TextStyle beltLabel = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
  );

  // ─── NARRATIVA ─────────────────────────────────────────────────────────────
  /// Para el scroll de intro estilo Star Wars.
  static const TextStyle narrative = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.goldLight,
    height: 1.8,
    letterSpacing: 0.3,
  );

  // ─── MONEDAS / PRECIOS ─────────────────────────────────────────────────────
  static const TextStyle currencyLarge = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.goldPrimary,
  );

  static const TextStyle currencySmall = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.goldPrimary,
  );

  static const TextStyle priceReal = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
