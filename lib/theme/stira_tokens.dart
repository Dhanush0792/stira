import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stira Design System Tokens — Master Prompt v1.0
/// Single source of truth. Import this everywhere.
/// Never hardcode a color, font size, or spacing value inline.
class StiraTokens {
  StiraTokens._();

  // ─── Background Colors ────────────────────────────────────────────
  static const Color stiraBg  = Color(0xFF07060F);
  static const Color stiraBg2 = Color(0xFF0D0B1A);

  // ─── Accent Colors ────────────────────────────────────────────────
  static const Color stiraPink   = Color(0xFFE8307A);
  static const Color stiraTeal   = Color(0xFF1ECFB3);
  static const Color stiraAmber  = Color(0xFFF5A623);
  static const Color stiraViolet = Color(0xFF7C4DFF);

  // ─── Glass / UI ───────────────────────────────────────────────────
  static const Color stiraWhite       = Color(0xFFF0EEF8);
  static const Color stiraMuted       = Color(0x73F0EEF8);   // 45% white
  static const Color stiraGlass       = Color(0x0EFFFFFF);   // 5.5% white
  static const Color stiraGlassBorder = Color(0x17FFFFFF);   // 9% white

  // ─── Accent Soft Fills ────────────────────────────────────────────
  static const Color stiraPinkSoft   = Color(0x2DE8307A);
  static const Color stiraTealSoft   = Color(0x261ECFB3);
  static const Color stiraAmberSoft  = Color(0x26F5A623);
  static const Color stiraVioletSoft = Color(0x267C4DFF);

  // ─── Spacing ──────────────────────────────────────────────────────
  static const double sp4  = 4;
  static const double sp8  = 8;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp24 = 24;
  static const double sp32 = 32;

  // ─── Shape ────────────────────────────────────────────────────────
  static const double radiusCard  = 18;
  static const double radiusBtn   = 14;
  static const double radiusInput = 14;

  // ─── LED Glow Shadow ─────────────────────────────────────────────
  static List<Shadow> ledGlow(Color color) => [
    Shadow(color: color.withValues(alpha: 0.55), blurRadius: 14),
  ];

  // ─── Typography ───────────────────────────────────────────────────
  static TextStyle displayHero = GoogleFonts.syne(
    fontSize: 32, fontWeight: FontWeight.w800,
    color: stiraWhite, height: 1.1, letterSpacing: -0.5,
  );

  static TextStyle displayTitle = GoogleFonts.syne(
    fontSize: 20, fontWeight: FontWeight.w700, color: stiraWhite,
  );

  static TextStyle sectionTitle = GoogleFonts.syne(
    fontSize: 16, fontWeight: FontWeight.w700, color: stiraWhite,
  );

  static TextStyle metricLarge = GoogleFonts.dmMono(
    fontSize: 28, fontWeight: FontWeight.w500, letterSpacing: 1.5,
    color: stiraPink,
    shadows: [Shadow(color: stiraPink.withValues(alpha: 0.55), blurRadius: 14)],
  );

  static TextStyle labelMono = GoogleFonts.dmMono(
    fontSize: 8.5, fontWeight: FontWeight.w400,
    color: stiraMuted, letterSpacing: 1.5,
  );

  static TextStyle bodyText = GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: stiraMuted, height: 1.6,
  );

  static TextStyle buttonLabel = GoogleFonts.syne(
    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
  );

  static TextStyle captionMono = GoogleFonts.dmMono(
    fontSize: 9, fontWeight: FontWeight.w400,
    color: stiraMuted, letterSpacing: 2,
  );

  // ─── Screen Background Gradients ──────────────────────────────────
  static const Decoration bgPinkTopGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, -1.0), radius: 0.9,
      colors: [Color(0x25E8307A), Colors.transparent],
    ),
  );

  static const Decoration bgAmberCenterGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, -0.5), radius: 1.5,
      colors: [Color(0x1FF5A623), Colors.transparent],
    ),
  );

  static const Decoration bgTealCenterGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, 0.1), radius: 0.9,
      colors: [Color(0x261ECFB3), Colors.transparent],
    ),
  );

  static const Decoration bgVioletTopRightGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0.6, -0.6), radius: 0.8,
      colors: [Color(0x267C4DFF), Colors.transparent],
    ),
  );

  static const Decoration bgVioletCenterGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, 0), radius: 1.0,
      colors: [Color(0x1A7C4DFF), Colors.transparent],
    ),
  );

  static const Decoration bgPinkTopCenterGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, -0.8), radius: 1.0,
      colors: [Color(0x1FE8307A), Colors.transparent],
    ),
  );

  // ─── Accent Rule ──────────────────────────────────────────────────
  // Home tab / Dashboard / Actions → stiraPink
  // Check-in / Tools → stiraTeal
  // Insights / Forecasts → stiraViolet
  // Stability / Forecast card → stiraAmber
  // Profile / Danger Zones → stiraPink

  // ─── Material ThemeData ───────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: stiraBg,
    colorScheme: const ColorScheme.dark(
      primary: stiraPink,
      secondary: stiraTeal,
      surface: stiraBg2,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: stiraBg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.syne(
        fontSize: 16, fontWeight: FontWeight.w700, color: stiraWhite,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
