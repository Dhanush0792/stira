import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/stira_tokens.dart';

/// StiraCardLabel — uppercase DM Mono tag above every metric card.
/// Props: text (String), color (Color, default stiraMuted)
class StiraCardLabel extends StatelessWidget {
  final String text;
  final Color color;

  const StiraCardLabel(
    this.text, {
    super.key,
    this.color = StiraTokens.stiraMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmMono(
        fontSize: 8.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        color: color,
      ),
    );
  }
}
