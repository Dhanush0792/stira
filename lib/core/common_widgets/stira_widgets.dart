import 'package:flutter/material.dart';
import '../../core/theme/earth_night.dart';
import '../../core/intelligence_layer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GradientBackground
// Adapts to BehaviorMode according to Phase 2 specs.
//   NeutralSupport: Slightly wider glow, softer gradient
//   AttentiveRegulation: Slightly tighter glow, slight dimming
//   ProtectiveContainment: Darker edges, glow compressed, visual containment
// ─────────────────────────────────────────────────────────────────────────────
class GradientBackground extends StatelessWidget {
  final Widget child;
  final BehaviorMode mode;

  const GradientBackground({
    super.key, 
    required this.child, 
    this.mode = BehaviorMode.neutralSupport,
  });

  @override
  Widget build(BuildContext context) {
    // Determine glow radius based on mode
    final double glowRadius = switch (mode) {
      BehaviorMode.neutralSupport => 1.2,
      BehaviorMode.attentiveRegulation => 0.9,
      BehaviorMode.protectiveContainment => 0.6,
    };

    final double glowAlpha = switch (mode) {
      BehaviorMode.neutralSupport => 0.08,
      BehaviorMode.attentiveRegulation => 0.05,
      BehaviorMode.protectiveContainment => 0.03, // compressed/contained
    };

    // Background intensity adjustment
    final Color baseBackground = switch (mode) {
      BehaviorMode.neutralSupport => EarthNight.backgroundDeep,
      BehaviorMode.attentiveRegulation => const Color(0xFF06060A),
      BehaviorMode.protectiveContainment => const Color(0xFF030305),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(color: baseBackground),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Subtle radial gradient from center
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: glowRadius,
                colors: [
                  EarthNight.accentViolet.withValues(alpha: glowAlpha),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          
          // 2. Faint vertical gradient noise layer (low opacity)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.015),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.03),
                ],
              ),
            ),
          ),

          // 3. Vignette edge fade
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.4,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.25),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FadeSlideEntrance
// Phase 4 Motion System transition wrapper.
// - fade + slight upward offset (8px)
// - duration 300ms
// - no bounce, no scale jump
// ─────────────────────────────────────────────────────────────────────────────
class FadeSlideEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const FadeSlideEntrance({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<FadeSlideEntrance> createState() => _FadeSlideEntranceState();
}

class _FadeSlideEntranceState extends State<FadeSlideEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - _fade.value)),
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SanctuaryCard
// Flattened surface panel without card shadows.
// ─────────────────────────────────────────────────────────────────────────────
class SanctuaryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SanctuaryCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 1),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF161620), // slightly lighter top
            Color(0xFF101017), // slightly darker bottom
          ],
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StiraButton
// Adaptive action button with soft glow elevation.
// ─────────────────────────────────────────────────────────────────────────────
class StiraButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;

  const StiraButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  State<StiraButton> createState() => _StiraButtonState();
}

class _StiraButtonState extends State<StiraButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glowAlpha;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _glowAlpha = Tween<double>(begin: 0.04, end: 0.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null) _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
  }

  void _onTapCancel() {
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: (!widget.isSecondary && enabled)
                    ? [
                        BoxShadow(
                          color: EarthNight.accentViolet.withValues(alpha: _glowAlpha.value),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: ElevatedButton(
                style: widget.isSecondary
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: enabled
                            ? EarthNight.textPrimary
                            : EarthNight.textSecondary,
                        side: BorderSide(
                          color: enabled
                              ? EarthNight.accentViolet.withValues(alpha: 0.3)
                              : EarthNight.textSecondary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      )
                    : ElevatedButton.styleFrom(
                        backgroundColor: enabled
                            ? EarthNight.surface
                            : EarthNight.surface.withValues(alpha: 0.5),
                        foregroundColor: enabled
                            ? EarthNight.textPrimary
                            : EarthNight.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                onPressed: widget.onPressed,
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: widget.isSecondary
                        ? (enabled
                            ? EarthNight.textPrimary
                            : EarthNight.textSecondary)
                        : (enabled
                            ? EarthNight.textPrimary
                            : EarthNight.textSecondary),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
