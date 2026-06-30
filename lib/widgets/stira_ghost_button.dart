import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/stira_tokens.dart';

/// StiraGhostButton — secondary action button.
/// Props: label, onTap
class StiraGhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final Color borderColor;

  const StiraGhostButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 48.0,
    this.borderColor = StiraTokens.stiraGlassBorder,
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
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: StiraTokens.stiraGlass,
            borderRadius: BorderRadius.circular(StiraTokens.radiusBtn),
            border: Border.all(color: widget.borderColor, width: 1),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: StiraTokens.stiraMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
