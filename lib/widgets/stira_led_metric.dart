import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/stira_tokens.dart';

/// StiraLedMetric — LED-style glowing number.
/// Props: value (String), unit (String), color (Color), size (double, default 28)
class StiraLedMetric extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;
  final double size;

  const StiraLedMetric({
    super.key,
    required this.value,
    required this.color,
    this.unit = '',
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: GoogleFonts.dmMono(
              fontSize: size,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: color,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.55),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
          if (unit.isNotEmpty)
            TextSpan(
              text: unit,
              style: GoogleFonts.dmMono(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w400,
                color: StiraTokens.stiraMuted,
              ),
            ),
        ],
      ),
    );
  }
}
