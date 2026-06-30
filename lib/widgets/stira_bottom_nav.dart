import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/stira_tokens.dart';

/// StiraBottomNav — 4-tab persistent nav bar.
/// Props: currentIndex (int), onTap (Function(int))
class StiraBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StiraBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.auto_graph_rounded, label: 'Insights'),
    _NavItem(icon: Icons.bolt_rounded, label: 'Tools'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  Color _getActiveColor(int index) {
    switch (index) {
      case 0: return StiraTokens.stiraPink;
      case 1: return StiraTokens.stiraViolet;
      case 2: return StiraTokens.stiraTeal;
      case 3: return StiraTokens.stiraAmber;
      default: return StiraTokens.stiraPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: StiraTokens.stiraBg.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: StiraTokens.stiraGlassBorder,
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final active = i == currentIndex;
                final color = active ? _getActiveColor(i) : StiraTokens.stiraMuted;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: active
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              )
                            : null,
                        child: Icon(
                          _tabs[i].icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _tabs[i].label.toUpperCase(),
                        style: GoogleFonts.dmMono(
                          fontSize: 7,
                          letterSpacing: 0.5,
                          color: color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
