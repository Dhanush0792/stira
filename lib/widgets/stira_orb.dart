import 'package:flutter/material.dart';
import '../theme/stira_tokens.dart';

/// StiraOrb — animated central state orb.
/// Props: intensity (0.0–1.0), size (default 110)
///
/// Color by intensity:
///   0.00–0.33 → stiraTeal
///   0.34–0.66 → stiraAmber
///   0.67–1.00 → stiraPink
class StiraOrb extends StatefulWidget {
  final double intensity;
  final double size;

  const StiraOrb({
    super.key,
    required this.intensity,
    this.size = 110,
  });

  @override
  State<StiraOrb> createState() => _StiraOrbState();
}

class _StiraOrbState extends State<StiraOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.6, end: 0.2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _orbColor() {
    final i = widget.intensity.clamp(0.0, 1.0);
    if (i <= 0.33) return StiraTokens.stiraTeal;
    if (i <= 0.66) return StiraTokens.stiraAmber;
    return StiraTokens.stiraPink;
  }

  @override
  Widget build(BuildContext context) {
    final orbColor = _orbColor();
    final s = widget.size;
    final ringSize = s + 32; // ring is 16px margin outside orb on each side

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _opacity.value,
                  child: Container(
                    width: ringSize,
                    height: ringSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: orbColor.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // Inner orb
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.2, -0.2),
                    radius: 0.8,
                    colors: [
                      orbColor.withValues(alpha: 0.95),
                      orbColor.withValues(alpha: 0.35),
                      orbColor.withValues(alpha: 0.08),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: orbColor.withValues(alpha: 0.4),
                      blurRadius: 50,
                    ),
                    BoxShadow(
                      color: orbColor.withValues(alpha: 0.15),
                      blurRadius: 100,
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
