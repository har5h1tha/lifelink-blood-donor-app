import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        primary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
        appBarColor: AppColors.primary,
        textColor: AppColors.textPrimary,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        appBarColor: AppColors.darkPrimary,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    required Color appBarColor,
    Color? textColor,
  }) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    var textTheme = base;
    if (textColor != null) {
      textTheme = textTheme.apply(bodyColor: textColor, displayColor: textColor);
    }
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: brightness)
          .copyWith(primary: primary, onPrimary: Colors.white, surface: surface),
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
