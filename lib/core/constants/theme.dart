import 'package:flutter/material.dart';

class AppColors {
  static const emerald = Color(0xFF1F6F5C);
  static const emeraldDeep = Color(0xFF0F4C3A);
  static const parchment = Color(0xFFF7F1E1);
  static const parchmentSoft = Color(0xFFFBF6E8);
  static const indigoDeep = Color(0xFF1A1A40);
  static const muted = Color(0xFF6B6B6B);
  static const gold = Color(0xFFC9A24B);
}

class AppRadius {
  static const card = 18.0;
  static const small = 8.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.parchment,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.emerald,
      secondary: AppColors.gold,
      surface: AppColors.parchmentSoft,
      onPrimary: AppColors.parchment,
      onSurface: AppColors.indigoDeep,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.indigoDeep,
      displayColor: AppColors.indigoDeep,
    ),
  );
}
