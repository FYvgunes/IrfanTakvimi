import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Parşömen" palette — warm ivory ground, deep emerald heritage cards,
/// copper/gold accents. Inspired by illuminated Ottoman manuscripts.
///
/// **Light palette only** — kept as `static const` so existing widgets that
/// build `const BoxDecoration/TextStyle` keep compiling. For dark-mode-aware
/// surfaces use `context.palette.*` (see [AppPalette]) instead.
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

/// Theme-aware palette. Read at runtime via `context.palette.*`.
///
/// Why this exists alongside [AppColors]: most widgets in this app build
/// `const` decorations with `AppColors.X`, which can't be runtime-swapped
/// between light/dark. New / migrated widgets should pull colors from this
/// extension instead so they react to the active [ThemeData.brightness].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color ground;        // page background
  final Color groundSoft;    // raised surface
  final Color heritage;      // deep emerald card (intentionally similar in both modes)
  final Color heritageEdge;  // card top accent
  final Color copper;        // primary accent
  final Color copperSoft;    // secondary accent
  final Color ink;           // body text on `ground`
  final Color inkMuted;      // muted text on `ground`
  final Color cream;         // body text on heritage card
  final Color creamMuted;    // muted on heritage card

  const AppPalette({
    required this.ground,
    required this.groundSoft,
    required this.heritage,
    required this.heritageEdge,
    required this.copper,
    required this.copperSoft,
    required this.ink,
    required this.inkMuted,
    required this.cream,
    required this.creamMuted,
  });

  @override
  AppPalette copyWith({
    Color? ground,
    Color? groundSoft,
    Color? heritage,
    Color? heritageEdge,
    Color? copper,
    Color? copperSoft,
    Color? ink,
    Color? inkMuted,
    Color? cream,
    Color? creamMuted,
  }) =>
      AppPalette(
        ground: ground ?? this.ground,
        groundSoft: groundSoft ?? this.groundSoft,
        heritage: heritage ?? this.heritage,
        heritageEdge: heritageEdge ?? this.heritageEdge,
        copper: copper ?? this.copper,
        copperSoft: copperSoft ?? this.copperSoft,
        ink: ink ?? this.ink,
        inkMuted: inkMuted ?? this.inkMuted,
        cream: cream ?? this.cream,
        creamMuted: creamMuted ?? this.creamMuted,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      ground: Color.lerp(ground, other.ground, t)!,
      groundSoft: Color.lerp(groundSoft, other.groundSoft, t)!,
      heritage: Color.lerp(heritage, other.heritage, t)!,
      heritageEdge: Color.lerp(heritageEdge, other.heritageEdge, t)!,
      copper: Color.lerp(copper, other.copper, t)!,
      copperSoft: Color.lerp(copperSoft, other.copperSoft, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
      creamMuted: Color.lerp(creamMuted, other.creamMuted, t)!,
    );
  }
}

const lightPalette = AppPalette(
  ground: AppColors.ivory,
  groundSoft: AppColors.ivorySoft,
  heritage: AppColors.heritage,
  heritageEdge: AppColors.heritageEdge,
  copper: AppColors.copper,
  copperSoft: AppColors.copperSoft,
  ink: AppColors.ink,
  inkMuted: AppColors.inkMuted,
  cream: AppColors.cream,
  creamMuted: AppColors.creamMuted,
);

/// Dark palette — "gece kandili": near-black coffee ground with the same
/// heritage emerald card. Copper accents brightened a touch for legibility.
const darkPalette = AppPalette(
  ground: Color(0xFF14110C),       // very dark coffee
  groundSoft: Color(0xFF1F1A12),   // slightly raised surface
  heritage: Color(0xFF11483A),     // emerald, a hair brighter than light mode
  heritageEdge: Color(0xFF0A2E26),
  copper: Color(0xFFD9A668),       // brighter copper for AA contrast
  copperSoft: Color(0xFFE6BE89),
  ink: Color(0xFFE8E0CC),          // cream as primary text
  inkMuted: Color(0xFF9C927D),
  cream: AppColors.cream,          // cream on heritage stays
  creamMuted: AppColors.creamMuted,
);

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? lightPalette;
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

/// Builds the app's ThemeData for the requested [brightness].
///
/// Both light and dark themes share typography, spacing, and chrome shape,
/// only the palette differs. Pulls colors from [lightPalette] / [darkPalette]
/// and attaches an [AppPalette] extension so context.palette works.
ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  final isDark = brightness == Brightness.dark;
  final palette = isDark ? darkPalette : lightPalette;
  final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: palette.ink,
    displayColor: palette.ink,
  );
  return base.copyWith(
    extensions: [palette],
    scaffoldBackgroundColor: palette.ground,
    colorScheme: base.colorScheme.copyWith(
      brightness: brightness,
      primary: palette.heritage,
      secondary: palette.copper,
      surface: palette.groundSoft,
      onPrimary: palette.cream,
      onSurface: palette.ink,
    ),
    textTheme: textTheme.copyWith(
      displayLarge: GoogleFonts.ebGaramond(
        fontSize: 36, fontWeight: FontWeight.w500, color: palette.ink),
      displayMedium: GoogleFonts.ebGaramond(
        fontSize: 28, fontWeight: FontWeight.w500, color: palette.ink),
      titleLarge: GoogleFonts.ebGaramond(
        fontSize: 22, fontWeight: FontWeight.w500, color: palette.ink),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.ground,
      foregroundColor: palette.ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.ebGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: palette.ink,
        letterSpacing: 0.5,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.groundSoft,
      indicatorColor: palette.copper.withOpacity(0.18),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: palette.ink,
          letterSpacing: 0.3,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: palette.copper);
        }
        return IconThemeData(color: palette.inkMuted);
      }),
    ),
    dividerColor: palette.copper.withOpacity(0.25),
  );
}
