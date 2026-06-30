import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/earth_night.dart';
import '../../core/risk_engine.dart';

class StabilityField extends StatefulWidget {
  final RiskLevel riskLevel;

  const StabilityField({
    super.key,
    required this.riskLevel,
  });

  @override
  State<StabilityField> createState() => _StabilityFieldState();
}

class _StabilityFieldState extends State<StabilityField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 6 second animation cycle
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getPrimaryColor() {
    switch (widget.riskLevel) {
      case RiskLevel.low:
        return EarthNight.riskStable;
      case RiskLevel.moderate:
        return EarthNight.riskRising;
      case RiskLevel.elevated:
      case RiskLevel.critical:
        return EarthNight.riskHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double value = _controller.value;
        final Color baseColor = _getPrimaryColor();

        // Animation logic based on RiskLevel
        double scale = 1.0;
        double orbScale = 1.0;
        double ringRotation = 0.0;
        double ringStrokeWidth = 2.0;

        switch (widget.riskLevel) {
          case RiskLevel.low:
            // Slow breathing animation
            scale = 1.0 + (value * 0.05);
            orbScale = 1.0 + (value * 0.08);
            ringRotation = value * math.pi * 0.1;
            break;
          case RiskLevel.moderate:
            // Tightening ring animation
            scale = 1.0;
            orbScale = 0.9 + (value * 0.1);
            ringRotation = value * math.pi * 0.25;
            ringStrokeWidth = 3.0 + (value * 2.0);
            break;
          case RiskLevel.elevated:
          case RiskLevel.critical:
            // Pressure ring effect
            scale = 0.95 + (value * 0.1);
            orbScale = 0.85 + (value * 0.15);
            ringRotation = value * math.pi * 0.5;
            ringStrokeWidth = 4.0 + (value * 3.0);
            break;
        }

        return Container(
          width: 200,
          height: 200,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow Aura
              Container(
                width: 160 * scale,
                height: 160 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.15 + (value * 0.1)),
                      blurRadius: 40 + (value * 20),
                      spreadRadius: 20 + (value * 10),
                    ),
                  ],
                ),
              ),
              // Outer Rings (3 pulsing gently)
              ...List.generate(3, (i) {
                return Transform.rotate(
                  angle: ringRotation * (i % 2 == 0 ? 1 : -1) + (i * math.pi / 4),
                  child: Container(
                    width: (140 + (i * 30)) * scale,
                    height: (140 + (i * 30)) * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: baseColor.withValues(alpha: math.max(0.05, 0.3 - (i * 0.08) + (value * 0.05))),
                        width: ringStrokeWidth * (1.0 - i * 0.1),
                      ),
                    ),
                  ),
                );
              }),
              // Inner Orb
              Container(
                width: 100 * orbScale,
                height: 100 * orbScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      baseColor.withValues(alpha: 0.8),
                      baseColor.withValues(alpha: 0.2),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
