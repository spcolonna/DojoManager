import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDeep,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.goldPrimary,
      secondary: AppColors.redAction,
      surface: AppColors.bgSurface,
      background: AppColors.bgDeep,
      error: AppColors.redLight,
      onPrimary: AppColors.bgDeep,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: AppColors.textPrimary,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.bgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDeep,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgSurface,
      selectedItemColor: AppColors.goldPrimary,
      unselectedItemColor: AppColors.textDisabled,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.bgDivider,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.bgDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.bgDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.textDisabled, fontFamily: 'Rajdhani'),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Rajdhani'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.goldPrimary,
        foregroundColor: AppColors.bgDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.goldPrimary,
        side: const BorderSide(color: AppColors.goldPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.goldPrimary,
      inactiveTrackColor: AppColors.bgInput,
      thumbColor: AppColors.goldLight,
      overlayColor: AppColors.overlayGold,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.goldPrimary,
      linearTrackColor: AppColors.bgInput,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.bgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.bgElevated,
      contentTextStyle: TextStyle(
        fontFamily: 'Rajdhani',
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
    ),
  );
}
