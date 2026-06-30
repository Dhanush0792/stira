import 'package:flutter/material.dart';

/// Mixin that drives staggered screen-entry animations.
///
/// Usage:
/// 1. Add `with TickerProviderStateMixin, StiraStaggerMixin` to your State class
///    (TickerProviderStateMixin MUST come first).
/// 2. Call `staggerItem(index, child)` on every card/content block.
///    Index 0 starts at 0ms, index 1 at 80ms, index 2 at 160ms, etc.
/// 3. All items fade in (opacity 0→1) + slide up (y +20px → 0),
///    duration 300ms, Curves.easeOutCubic.
mixin StiraStaggerMixin<T extends StatefulWidget> on State<T> {
  late final AnimationController _staggerCtrl;
  // Maximum items supported per screen — drives total duration
  static const int _maxItems = 16;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this as TickerProvider,
      // Each item: 80ms delay + 300ms duration
      duration: const Duration(milliseconds: 80 * _maxItems + 300),
    );
    // Auto-start on mount
    _staggerCtrl.forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  /// Wraps [child] with a staggered opacity + slide-up entry animation.
  /// [index] determines the 80ms delay offset (0-indexed).
  Widget staggerItem(int index, Widget child) {
    const int totalMs = 80 * _maxItems + 300;
    final startMs = 80 * index;
    final endMs = startMs + 300;
    final start = startMs / totalMs;
    final end = (endMs / totalMs).clamp(0.0, 1.0);

    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.04), // ~20px slide on typical screen
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }
}
