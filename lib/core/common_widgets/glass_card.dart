import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/local_storage.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isLowPerf = StorageService().isLowPerformanceMode();

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: isLowPerf ? 0.25 : 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: isLowPerf ? null : const [
          BoxShadow(
            color: Color(0x59000000),
            offset: Offset(0, 20),
            blurRadius: 40,
          ),
        ],
      ),
      child: child,
    );

    if (isLowPerf) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: content,
      ),
    );
  }
}
