import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/stira_tokens.dart';

/// Milestone day values. Show overlay once per milestone.
const List<int> _milestones = [3, 7, 14, 30, 60, 90, 180, 365];

const String _prefPrefix = 'milestone_shown_';

/// Call this after a streak value changes to show the milestone overlay
/// once per milestone.  Handles the SharedPreferences guard internally.
Future<void> showMilestoneIfNeeded(BuildContext context, int streakDays) async {
  if (!_milestones.contains(streakDays)) return;
  final prefs = await SharedPreferences.getInstance();
  final key = '$_prefPrefix$streakDays';
  if (prefs.getBool(key) == true) return;
  await prefs.setBool(key, true);
  if (!context.mounted) return;
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss milestone',
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (ctx, anim, _, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          ),
          child: child,
        ),
      );
    },
    pageBuilder: (ctx, _, __) => _MilestoneOverlay(days: streakDays),
  );
}

class _MilestoneOverlay extends StatelessWidget {
  final int days;
  const _MilestoneOverlay({required this.days});

  String get _emoji {
    if (days >= 365) return '🏆';
    if (days >= 180) return '🌟';
    if (days >= 90) return '💎';
    if (days >= 60) return '✨';
    if (days >= 30) return '🔥';
    if (days >= 14) return '⚡';
    return '🌱';
  }

  String get _subtitle {
    if (days >= 365) return 'A full year of stability.';
    if (days >= 180) return 'Six months. Remarkable.';
    if (days >= 90) return 'Three months of consistency.';
    if (days >= 60) return 'Two-month mark hit.';
    if (days >= 30) return 'A full month. You\'re building real change.';
    if (days >= 14) return 'Two weeks in. The pattern is forming.';
    if (days >= 7) return 'One week clean. It matters more than you know.';
    return 'Three days. A real start.';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Amber radial glow background
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    StiraTokens.stiraAmber.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _emoji,
                    style: const TextStyle(fontSize: 52),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$days days.',
                    style: GoogleFonts.syne(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: StiraTokens.stiraAmber,
                      shadows: [
                        Shadow(
                          color: StiraTokens.stiraAmber.withValues(alpha: 0.6),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      _subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: StiraTokens.stiraWhite.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'TAP TO CONTINUE',
                    style: GoogleFonts.dmMono(
                      fontSize: 9,
                      color: StiraTokens.stiraMuted,
                      letterSpacing: 2,
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
