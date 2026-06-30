import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/stira_tokens.dart';

class StiraBackgroundOrbs extends StatefulWidget {
  const StiraBackgroundOrbs({super.key});

  @override
  State<StiraBackgroundOrbs> createState() => _StiraBackgroundOrbsState();
}

class _StiraBackgroundOrbsState extends State<StiraBackgroundOrbs> with SingleTickerProviderStateMixin {
  late Timer _timer;
  final Random _random = Random();
  
  // Orb positions
  double _orb1X = 0.2;
  double _orb1Y = 0.2;
  double _orb2X = 0.8;
  double _orb2Y = 0.8;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _orb1X = _random.nextDouble();
          _orb1Y = _random.nextDouble();
          _orb2X = _random.nextDouble();
          _orb2Y = _random.nextDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          _AnimatedOrb(
            x: _orb1X,
            y: _orb1Y,
            color: StiraTokens.stiraViolet.withValues(alpha: 0.15),
            size: 350,
          ),
          _AnimatedOrb(
            x: _orb2X,
            y: _orb2Y,
            color: StiraTokens.stiraTeal.withValues(alpha: 0.12),
            size: 300,
          ),
        ],
      ),
    );
  }
}

class _AnimatedOrb extends StatelessWidget {
  final double x;
  final double y;
  final Color color;
  final double size;

  const _AnimatedOrb({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: Alignment(x * 2 - 1, y * 2 - 1),
      duration: const Duration(seconds: 4),
      curve: Curves.easeInOutSine,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}
