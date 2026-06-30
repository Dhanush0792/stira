import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/stira_tokens.dart';

/// Rotary dial widget for urge intensity 1-10.
/// 
/// Outer ring rotates 20s linear repeat.
/// Inner disc counter-rotates.
/// GestureDetector calculates angle → maps to 1–10.
/// HapticFeedback.selectionClick() fires once per integer change.
class StiraRadialDial extends StatefulWidget {
  final int value;
  final Color color;
  /// Called every time the integer value changes (1-10).
  final ValueChanged<int> onChanged;
  final double size;

  const StiraRadialDial({
    super.key,
    required this.value,
    required this.onChanged,
    this.color = StiraTokens.stiraTeal,
    this.size = 200,
  });

  @override
  State<StiraRadialDial> createState() => _StiraRadialDialState();
}

class _StiraRadialDialState extends State<StiraRadialDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotateCtrl;

  // Track touch angle for drag gesture
  double _startAngle = 0;
  int _startValue = 5;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details, Offset center) {
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    _startAngle = math.atan2(dy, dx);
    _startValue = widget.value;
  }

  void _onPanUpdate(DragUpdateDetails details, Offset center) {
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    final currentAngle = math.atan2(dy, dx);
    // Difference in radians, normalised
    var delta = currentAngle - _startAngle;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;

    // Map full rotation (2*pi) to a range of ±10 integers
    final steps = (delta / (2 * math.pi) * 20).round();
    final newVal = (_startValue + steps).clamp(1, 10);
    if (newVal != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(newVal);
    }
  }

  Color get _dialColor {
    final v = widget.value;
    if (v <= 3) return StiraTokens.stiraTeal;
    if (v <= 6) return StiraTokens.stiraAmber;
    return StiraTokens.stiraPink;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final outerRingDiam = s * 0.70;
    final innerDiscDiam = s * 0.45;
    final color = _dialColor;

    return SizedBox(
      width: s,
      height: s,
      child: LayoutBuilder(
        builder: (ctx, _) {
          final center = Offset(s / 2, s / 2);
          return GestureDetector(
            onPanStart: (d) => _onPanStart(d, center),
            onPanUpdate: (d) => _onPanUpdate(d, center),
            child: AnimatedBuilder(
              animation: _rotateCtrl,
              builder: (_, __) {
                final outerAngle = _rotateCtrl.value * 2 * math.pi;
                final innerAngle = -outerAngle; // counter-rotation

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    Transform.rotate(
                      angle: outerAngle,
                      child: CustomPaint(
                        size: Size(outerRingDiam, outerRingDiam),
                        painter: _DashedRingPainter(
                          color: color.withValues(alpha: 0.35),
                          strokeWidth: 1.5,
                          dashCount: 36,
                        ),
                      ),
                    ),

                    // Inner counter-rotating disc
                    Transform.rotate(
                      angle: innerAngle,
                      child: Container(
                        width: innerDiscDiam,
                        height: innerDiscDiam,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.3),
                            radius: 1.0,
                            colors: [
                              color.withValues(alpha: 0.45),
                              color.withValues(alpha: 0.08),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Center metric
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.value}',
                          style: GoogleFonts.dmMono(
                            fontSize: s * 0.22,
                            fontWeight: FontWeight.w500,
                            color: color,
                            shadows: [
                              Shadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '/10',
                          style: GoogleFonts.dmMono(
                            fontSize: s * 0.06,
                            color: StiraTokens.stiraMuted,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  const _DashedRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;
    final dashAngle = (2 * math.pi) / dashCount;
    const gapFraction = 0.4; // 40% gap

    for (int i = 0; i < dashCount; i++) {
      final startAngle = dashAngle * i;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
