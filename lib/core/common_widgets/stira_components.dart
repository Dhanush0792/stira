import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/earth_night.dart';

// ═══════════════════════════════════════════════════════════════════
// StiraGlassCard
// Glassmorphic card used for ALL data cards in the app.
// ═══════════════════════════════════════════════════════════════════
class StiraGlassCard extends StatelessWidget {
  final Color accentColor;
  final Widget child;
  final bool spanFull;
  final EdgeInsets padding;

  const StiraGlassCard({
    super.key,
    required this.accentColor,
    required this.child,
    this.spanFull = false,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: spanFull ? double.infinity : null,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.18),
                accentColor.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.22),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              // Subtle radial glow top-right corner
              Positioned(
                top: -16,
                right: -16,
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
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// StiraLedMetric
// LED-style glowing metric display using DM Mono
// ═══════════════════════════════════════════════════════════════════
class StiraLedMetric extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;
  final double size;

  const StiraLedMetric({
    super.key,
    required this.value,
    required this.color,
    this.unit = '',
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: GoogleFonts.dmMono(
              fontSize: size,
              fontWeight: FontWeight.w500,
              color: color,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.55),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          if (unit.isNotEmpty)
            TextSpan(
              text: unit,
              style: GoogleFonts.dmMono(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w400,
                color: stiraMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// StiraCardLabel
// Uppercase monospaced label above every card metric
// ═══════════════════════════════════════════════════════════════════
class StiraCardLabel extends StatelessWidget {
  final String text;
  final Color color;

  const StiraCardLabel(
    this.text, {
    super.key,
    this.color = stiraMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmMono(
        fontSize: 8.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        color: color,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// StiraPrimaryButton
// Main CTA button — colored gradient with glow shadow
// ═══════════════════════════════════════════════════════════════════
class StiraPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double? width;

  const StiraPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = stiraPink,
    this.width,
  });

  @override
  State<StiraPrimaryButton> createState() => _StiraPrimaryButtonState();
}

class _StiraPrimaryButtonState extends State<StiraPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: (_) {
        if (enabled) _ctrl.forward();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color,
                  widget.color.withValues(alpha: 0.75),
                ],
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.35),
                        offset: const Offset(0, 8),
                        blurRadius: 24,
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// StiraGhostButton
// Secondary glass border button
// ═══════════════════════════════════════════════════════════════════
class StiraGhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const StiraGhostButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<StiraGhostButton> createState() => _StiraGhostButtonState();
}

class _StiraGhostButtonState extends State<StiraGhostButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: stiraGlassBorder, width: 1),
              color: stiraGlass,
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: stiraMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// StiraDestructiveText
// For Reset button ONLY — shows confirmation before executing
// ═══════════════════════════════════════════════════════════════════
class StiraDestructiveText extends StatelessWidget {
  final String label;
  final VoidCallback onConfirm;

  const StiraDestructiveText({
    super.key,
    required this.label,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: stiraBg2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: stiraPink.withValues(alpha: 0.3)),
            ),
            title: Text(
              'Reset your streak?',
              style: GoogleFonts.syne(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: stiraWhite,
              ),
            ),
            content: Text(
              'This cannot be undone.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: stiraMuted,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.syne(color: stiraMuted, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Confirm',
                  style: GoogleFonts.syne(
                    color: stiraPink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          onConfirm();
        }
      },
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: stiraPink.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// StiraOrb
// Animated central state orb. Intensity 0–1 maps to color.
//   0.00–0.33 → stiraTeal  (calm/stable)
//   0.34–0.66 → stiraAmber (moderate)
//   0.67–1.00 → stiraPink  (high risk)
// ═══════════════════════════════════════════════════════════════════
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
  late final Animation<double> _pulse;

  Color get _orbColor {
    if (widget.intensity <= 0.33) return stiraTeal;
    if (widget.intensity <= 0.66) return stiraAmber;
    return stiraPink;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _orbColor;
    final orb = widget.size;
    final ring = orb + 32;

    return SizedBox(
      width: ring,
      height: ring,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final ringOpacity = 0.2 + (_pulse.value * 0.4);
          final ringScale = 1.0 + (_pulse.value * 0.06);
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: ring,
                  height: ring,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: ringOpacity * 0.25),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Inner orb
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: orb,
                height: orb,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.24, -0.36),
                    stops: const [0.0, 0.55, 0.80, 1.0],
                    colors: [
                      color.withValues(alpha: 0.95),
                      color.withValues(alpha: 0.55),
                      color.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4 + _pulse.value * 0.1),
                      blurRadius: 50,
                    ),
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// StiraBottomNav
// Persistent bottom navigation bar with pink active glow
// ═══════════════════════════════════════════════════════════════════
class StiraBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StiraBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _icons = [
    Icons.home_outlined,
    Icons.bar_chart_outlined,
    Icons.self_improvement_outlined,
    Icons.person_outline,
  ];
  static const _activeIcons = [
    Icons.home,
    Icons.bar_chart,
    Icons.self_improvement,
    Icons.person,
  ];
  static const _labels = ['Home', 'Insights', 'Tools', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 60 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: stiraBg.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(color: stiraGlassBorder, width: 1),
            ),
          ),
          child: Row(
            children: List.generate(4, (index) {
              final isActive = currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? _activeIcons[index] : _icons[index],
                        color: isActive ? stiraPink : stiraMuted,
                        size: 22,
                        shadows: isActive
                            ? [
                                Shadow(
                                  color: stiraPink.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _labels[index],
                        style: GoogleFonts.dmMono(
                          fontSize: 7,
                          letterSpacing: 0.5,
                          color: isActive ? stiraPink : stiraMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// StiraRadialDial
// Radial drag dial for check-in intensity (1–10)
// ═══════════════════════════════════════════════════════════════════
class StiraRadialDial extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;

  const StiraRadialDial({
    super.key,
    required this.value,
    required this.onChanged,
    this.color = stiraTeal,
  });

  @override
  State<StiraRadialDial> createState() => _StiraRadialDialState();
}

class _StiraRadialDialState extends State<StiraRadialDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotCtrl;
  final GlobalKey _dialKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  void _handlePan(Offset localPos) {
    final box = _dialKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final angle = math.atan2(localPos.dy - center.dy, localPos.dx - center.dx);
    // Map angle (-pi to pi) to 1-10
    // We rotate so 12-o-clock is the start
    final normalized = (angle + math.pi / 2 + math.pi * 2) % (math.pi * 2);
    final newValue = ((normalized / (math.pi * 2)) * 9).round() + 1;
    final clamped = newValue.clamp(1, 10);
    if (clamped != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: GestureDetector(
        key: _dialKey,
        onPanUpdate: (d) => _handlePan(d.localPosition),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating dashed ring
            AnimatedBuilder(
              animation: _rotCtrl,
              builder: (_, child) => Transform.rotate(
                angle: _rotCtrl.value * 2 * math.pi,
                child: child,
              ),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.3),
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
              ),
            ),
            // Inner disc (counter-rotating feel via static + spinning tracks)
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color.withValues(alpha: 0.3),
                    widget.color.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.25),
                    blurRadius: 30,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StiraLedMetric(
                    value: '${widget.value}',
                    unit: '/10',
                    color: widget.color,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'URGE',
                    style: GoogleFonts.dmMono(
                      fontSize: 7,
                      color: widget.color.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
