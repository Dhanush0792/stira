import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/stira_tokens.dart';
import '../services/local_storage.dart';

/// StiraGlassCard — glassmorphic card used on every screen.
/// Props: accentColor, child, padding, fullWidth
class StiraGlassCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final EdgeInsets padding;
  final bool fullWidth;
  final double? width;
  final double? height;

  const StiraGlassCard({
    super.key,
    required this.child,
    this.accentColor = StiraTokens.stiraPink,
    this.padding = const EdgeInsets.all(14),
    this.fullWidth = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Optimization: Skip BackdropFilter if in low performance mode or if disabled
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
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(StiraTokens.radiusCard),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Subtle glow orb in top-right corner
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          child,
        ],
      ),
    );

    if (isLowPerf) {
      return SizedBox(
        width: fullWidth ? double.infinity : width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(StiraTokens.radiusCard),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(StiraTokens.radiusCard),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Reduced from 10
          child: content,
        ),
      ),
    );
  }
}
