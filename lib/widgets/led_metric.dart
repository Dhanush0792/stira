import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/stira_theme.dart';

/// LED-style glowing metric display.
/// [value] — the large number/text
/// [unit]  — small suffix (e.g. "d", "%", "/10")
/// [accentColor] — glow + text color
class LedMetric extends StatelessWidget {
  final String value;
  final String unit;
  final Color accentColor;
  final double valueFontSize;

  const LedMetric({
    super.key,
    required this.value,
    required this.accentColor,
    this.unit = '',
    this.valueFontSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: GoogleFonts.dmMono(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: accentColor,
              shadows: [
                Shadow(
                  color: accentColor.withValues(alpha: 0.6),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
          if (unit.isNotEmpty)
            TextSpan(
              text: unit,
              style: GoogleFonts.dmMono(
                fontSize: valueFontSize * 0.38,
                fontWeight: FontWeight.w400,
                color: accentColor.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small uppercase DM Mono label (used above every metric)
class MonoLabel extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const MonoLabel(
    this.text, {
    super.key,
    this.color = StiraTheme.textMuted,
    this.fontSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmMono(
        fontSize: fontSize,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w400,
        color: color,
      ),
    );
  }
}

/// Primary gradient CTA button
class PrimaryButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = StiraTheme.pink,
    this.height = 52,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween(begin: 1.0, end: 0.96).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: (_) { if (enabled) _ctrl.forward(); },
      onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          width: double.infinity,
          height: widget.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c, _darken(c, 0.18)],
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: c.withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                widget.label,
                style: GoogleFonts.syne(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
