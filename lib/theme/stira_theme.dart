import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stira Design System — v2
/// Central token file. Every screen and widget imports this.
/// Never hardcode a color, font, or spacing anywhere else.
class StiraTheme {
  StiraTheme._();

  // ─── Backgrounds ─────────────────────────────────────────────────
  static const Color bgDeep  = Color(0xFF07060F);
  static const Color bgCard  = Color(0xFF0D0B1A);

  // ─── Accent Colors ───────────────────────────────────────────────
  static const Color pink   = Color(0xFFE8307A);
  static const Color teal   = Color(0xFF1ECFB3);
  static const Color amber  = Color(0xFFF5A623);
  static const Color violet = Color(0xFF7C4DFF);

  // ─── Glass / UI ──────────────────────────────────────────────────
  static const Color glassWhite   = Color(0x0EFFFFFF);  // 5.5% white
  static const Color glassBorder  = Color(0x17FFFFFF);  // 9% white
  static const Color textPrimary  = Color(0xFFF0EEF8);
  static const Color textMuted    = Color(0x73F0EEF8);  // 45% opacity

  // ─── Accent Soft Fills ───────────────────────────────────────────
  static const Color pinkSoft   = Color(0x2DE8307A);
  static const Color tealSoft   = Color(0x261ECFB3);
  static const Color amberSoft  = Color(0x26F5A623);
  static const Color violetSoft = Color(0x267C4DFF);

  // ─── Typography ──────────────────────────────────────────────────
  static TextStyle displayHero = GoogleFonts.syne(
    fontSize: 32, fontWeight: FontWeight.w800,
    color: textPrimary, height: 1.1, letterSpacing: -0.5,
  );

  static TextStyle displayTitle = GoogleFonts.syne(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle sectionTitle = GoogleFonts.syne(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle metricLED = GoogleFonts.dmMono(
    fontSize: 32, fontWeight: FontWeight.w500,
    color: pink, letterSpacing: 1.5,
    shadows: const [Shadow(color: Color(0xFFE8307A), blurRadius: 12)],
  );

  static TextStyle labelMono = GoogleFonts.dmMono(
    fontSize: 10, fontWeight: FontWeight.w400,
    color: textMuted, letterSpacing: 2.5,
  );

  static TextStyle bodyText = GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: textMuted, height: 1.6,
  );

  static TextStyle buttonText = GoogleFonts.syne(
    fontSize: 14, fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  // ─── Radial Glow Overlays ────────────────────────────────────────
  /// Pink glow for top of screen (splash, signup, onboarding)
  static const Decoration pinkTopGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, -1.0),
      radius: 0.9,
      colors: [Color(0x25E8307A), Colors.transparent],
    ),
  );

  /// Amber glow for dashboard behind orb
  static const Decoration amberCenterGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, -0.5),
      radius: 1.5,
      colors: [Color(0x1FF5A623), Colors.transparent],
    ),
  );

  /// Teal glow for check-in
  static const Decoration tealCenterGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, 0.1),
      radius: 0.9,
      colors: [Color(0x261ECFB3), Colors.transparent],
    ),
  );

  /// Violet glow (insights, top-right)
  static const Decoration violetTopRightGlow = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0.6, -0.6),
      radius: 0.8,
      colors: [Color(0x267C4DFF), Colors.transparent],
    ),
  );

  // ─── Button Decorations ──────────────────────────────────────────
  static BoxDecoration primaryButton({Color color = pink}) => BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [color, _darken(color, 0.2)],
    ),
    boxShadow: [
      BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8)),
    ],
  );

  static Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
