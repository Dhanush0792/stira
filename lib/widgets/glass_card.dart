import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/stira_theme.dart';
import '../services/local_storage.dart';

/// Glassmorphic card — used on every screen.
/// Accepts an accentColor that tints the gradient and border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const GlassCard({
    super.key,
    required this.child,
    this.accentColor = StiraTheme.pink,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isLowPerf = StorageService().isLowPerformanceMode();

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: isLowPerf ? 0.35 : 0.18),
            accentColor.withValues(alpha: isLowPerf ? 0.25 : 0.04),
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          // Subtle corner radial highlight
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.07),
              ),
            ),
          ),
          child,
        ],
      ),
    );

    if (isLowPerf) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Reduced from 16
          child: content,
        ),
      ),
    );
  }
}
