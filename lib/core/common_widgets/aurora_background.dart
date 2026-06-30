import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/earth_night.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 15 seconds slow-motion animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark Base Layer
        Container(color: EarthNight.background),

        // Animated Aurora Blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final double value = _controller.value;
            final Size size = MediaQuery.of(context).size;

            return Stack(
              children: [
                // Top-left/center violet glow
                Positioned(
                  top: -size.height * 0.1 + (value * 100),
                  left: -size.width * 0.2 + (value * 50),
                  child: Container(
                    width: size.width * 1.2,
                    height: size.height * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          EarthNight.accentViolet.withValues(alpha: 0.25),
                          EarthNight.accentViolet.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom-right indigo/teal glow
                Positioned(
                  bottom: -size.height * 0.1 - (value * 80),
                  right: -size.width * 0.3 + (value * 60),
                  child: Container(
                    width: size.width * 1.3,
                    height: size.height * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          EarthNight.accentTeal.withValues(alpha: 0.20),
                          EarthNight.accentTeal.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Middle right magenta subtle glow
                Positioned(
                  top: size.height * 0.3 + (value * 120),
                  right: -size.width * 0.4,
                  child: Container(
                    width: size.width,
                    height: size.width,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          EarthNight.accentMagenta.withValues(alpha: 0.20),
                          EarthNight.accentMagenta.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // BackdropFilter removed for extreme performance optimization.
        // The RadialGradients on the blobs handle the fading edge smoothly.

        // Content over the background
        widget.child,
      ],
    );
  }
}
