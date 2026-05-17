import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Parşömen" palette — warm ivory ground, deep emerald heritage cards,
/// copper/gold accents. Inspired by illuminated Ottoman manuscripts.
class AppColors {
  // Ground & surfaces
  static const ivory = Color(0xFFF6EFD9);        // page background
  static const ivorySoft = Color(0xFFFBF7E8);    // raised flat surface (rare)
  static const heritage = Color(0xFF0E3A2F);     // deep emerald card
  static const heritageEdge = Color(0xFF072721); // card top accent / divider

  // Accents
  static const copper = Color(0xFFB07A2A);       // primary accent (next prayer dot, header rule)
  static const copperSoft = Color(0xFFD9A668);   // hover/secondary accent

  // Text
  static const ink = Color(0xFF2A1F0E);          // body text on ivory
  static const inkMuted = Color(0xFF6B5C42);     // captions / meta on ivory
  static const cream = Color(0xFFE8E0CC);        // body text on heritage card
  static const creamMuted = Color(0xFFB5A988);   // muted on heritage card

  // Legacy aliases kept so old refs compile while we migrate screens.
  // Remove once every screen is on the new palette.
  static const emerald = heritage;
  static const emeraldDeep = heritageEdge;
  static const parchment = ivory;
  static const parchmentSoft = ivorySoft;
  static const indigoDeep = ink;
  static const muted = inkMuted;
  static const gold = copper;
}

class AppRadius {
  static const card = 14.0;
  static const small = 8.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Display / heading face — EB Garamond serif, calligraphic feel.
TextStyle displayFont({
  double size = 28,
  FontWeight weight = FontWeight.w500,
  Color color = AppColors.ink,
  double letterSpacing = 0.2,
}) =>
    GoogleFonts.ebGaramond(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );

/// Body face — Inter, clean transitional sans.
TextStyle bodyFont({
  double size = 15,
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.ink,
  double letterSpacing = 0.1,
  double? height,
}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.ivory,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.heritage,
      secondary: AppColors.copper,
      surface: AppColors.ivorySoft,
      onPrimary: AppColors.cream,
      onSurface: AppColors.ink,
    ),
    textTheme: textTheme.copyWith(
      displayLarge: GoogleFonts.ebGaramond(
        fontSize: 36, fontWeight: FontWeight.w500, color: AppColors.ink),
      displayMedium: GoogleFonts.ebGaramond(
        fontSize: 28, fontWeight: FontWeight.w500, color: AppColors.ink),
      titleLarge: GoogleFonts.ebGaramond(
        fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.ink),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.ivory,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.ebGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
        letterSpacing: 0.5,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.ivorySoft,
      indicatorColor: AppColors.copper.withOpacity(0.18),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
          letterSpacing: 0.3,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.copper);
        }
        return const IconThemeData(color: AppColors.inkMuted);
      }),
    ),
    dividerColor: AppColors.copper.withOpacity(0.25),
  );
}
