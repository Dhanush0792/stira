import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/stira_tokens.dart';

/// StiraPrimaryButton — main CTA button.
/// Props: label, onTap, color (default stiraPink), isLoading
class StiraPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool isLoading;
  final double height;
  final TextStyle? textStyle;

  const StiraPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = StiraTokens.stiraPink,
    this.height = 48.0,
    this.isLoading = false,
    this.textStyle,
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
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null && !widget.isLoading;
    final c = widget.color;

    return GestureDetector(
      onTapDown: (_) { if (enabled) _ctrl.forward(); },
      onTapUp: (_) {
        _ctrl.reverse();
        if (enabled) widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          width: double.infinity,
          height: widget.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(StiraTokens.radiusBtn),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c, _darken(c, 0.20)],
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: c.withValues(alpha: 0.35),
                        offset: const Offset(0, 8),
                        blurRadius: 24,
                      ),
                    ]
                  : [],
            ),
            child: Opacity(
              opacity: (enabled || widget.isLoading) ? 1.0 : 0.4,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        )
                      : Text(
                          key: const ValueKey('text'),
                          widget.label,
                          style: widget.textStyle ?? GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
