import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
// STIRA BRAND COLOR TOKENS (v2)
// ════════════════════════════════════════════════════════
const Color stiraPink       = Color(0xFFE8307A);
const Color stiraTeal       = Color(0xFF1ECFB3);
const Color stiraAmber      = Color(0xFFF5A623);
const Color stiraViolet     = Color(0xFF7C4DFF);
const Color stiraBg         = Color(0xFF07060F);
const Color stiraBg2        = Color(0xFF0D0B1A);
const Color stiraWhite      = Color(0xFFF0EEF8);
const Color stiraMuted      = Color(0x73F0EEF8); // ~45% opacity
const Color stiraGlass      = Color(0x0EFFFFFF); // ~5.5% white
const Color stiraGlassBorder= Color(0x17FFFFFF); // ~9% white

/// Midnight Sanctuary design system.
/// Class is kept as EarthNight so all existing imports remain valid.
class EarthNight {
  // ── Background ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0B0F1A); // Dark base layer
  static const Color backgroundDeep = Color(0xFF080B14); // Slightly deeper for nav or deep elements

  // ── Surfaces ─────────────────────────────────────────────────────────────
  // Glassmorphic background will be handled by GlassCard, this is a fallback
  static const Color surface = Color(0x0DFFFFFF); // rgba(255,255,255,0.05) fallback

  // ── Aurora Glow Colors ───────────────────────────────────────────────────
  static const Color accentViolet = Color(0xFF7C5CFF);
  static const Color accentIndigo = Color(0xFF4A6CFF);
  static const Color accentMagenta = Color(0xFFFF5C9C);
  static const Color accentTeal = Color(0xFF3CE3D1);

  // Alias for backward compatibility if needed
  static const Color accentSage = accentViolet;

  // ── Risk States ──────────────────────────────────────────────────────────
  static const Color riskStable = Color(0xFF7C5CFF);
  static const Color riskRising = Color(0xFFFFB84A);
  static const Color riskHigh = Color(0xFFFF5C5C);

  // Kept for backward compatibility
  static const Color riskModerate = riskRising;
  static const Color riskElevated = riskHigh;

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F7FF);
  static const Color textSecondary = Color(0xFF9AA3B2);

  // ── Glow ─────────────────────────────────────────────────────────────────
  static const Color glowViolet = Color(0x267C5CFF); // ~15% opacity

  // ── Theme ─────────────────────────────────────────────────────────────────

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['SF Pro', 'Roboto', 'sans-serif'],
      colorScheme: const ColorScheme.dark(
        primary: accentViolet,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 30, // Primary title
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 26, // Metric numbers
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16, height: 1.5, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14, height: 1.5, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12, height: 1.5, fontWeight: FontWeight.normal),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentViolet.withValues(alpha: 0.5), width: 1.0),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textSecondary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundDeep,
        selectedItemColor: accentViolet.withValues(alpha: 0.9),
        unselectedItemColor: textSecondary.withValues(alpha: 0.5),
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadePageTransitionsBuilder(),
          TargetPlatform.iOS: FadePageTransitionsBuilder(),
          TargetPlatform.windows: FadePageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Custom transition builder for smooth cross-fades
class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
