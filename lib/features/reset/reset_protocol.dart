import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../services/local_storage.dart';
import '../../services/telemetry_service.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/auth_service.dart';

/// The "Compassionate Autopsy" — Blameless relapse logging with
/// Stira's full glassmorphism design language.
class ResetProtocol extends ConsumerStatefulWidget {
  const ResetProtocol({super.key});

  @override
  ConsumerState<ResetProtocol> createState() => _ResetProtocolState();
}

class _ResetProtocolState extends ConsumerState<ResetProtocol>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _step = 0;

  String? _location;
  String? _emotion;
  String? _trigger;

  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 3) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final storage = StorageService();

    if (_location != null && _emotion != null && _trigger != null) {
      await storage.addRelapseTrigger({
        'timestamp': DateTime.now().toIso8601String(),
        'location': _location,
        'emotion': _emotion,
        'trigger': _trigger,
      });
      await TelemetryService.trackRelapseLogged(_trigger!, _emotion!);
    }

    await storage.setLastRelapseDate(DateTime.now());
    await storage.updateDaysSteady(0);
    await storage.activateGhostMode();

    // Immediately sync to cloud so streak reset is persisted
    unawaited(() async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await CloudSyncService(
            FirebaseFirestore.instance,
            AuthService(FirebaseAuth.instance),
            StorageService(),
          ).syncHistoryToCloud();
        }
      } catch (e) {
        debugPrint('Reset cloud sync failed (non-fatal): $e');
      }
    }());

    setState(() => _completed = true);

    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Animated background glow
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Positioned(
              top: MediaQuery.of(context).size.height / 2 - 200,
              left: MediaQuery.of(context).size.width / 2 - 200,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      StiraTokens.stiraTeal.withValues(alpha: 0.06 + _glowAnim.value * 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: _completed
                ? _CompletedView()
                : Column(
                    children: [
                      // Header with close button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: StiraTokens.stiraGlass,
                                  border: Border.all(color: StiraTokens.stiraGlassBorder),
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white54, size: 16),
                              ),
                            ),
                            const Spacer(),
                            // Step progress pills
                            Row(
                              children: List.generate(4, (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(left: 6),
                                width: _step == i ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: i <= _step
                                      ? StiraTokens.stiraTeal
                                      : StiraTokens.stiraGlassBorder,
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: PageView(
                          controller: _pageCtrl,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _IntroPage(onNext: _next),
                            _SelectionPage(
                              stepLabel: 'STEP 1 OF 3',
                              title: 'Where were you\nwhen it happened?',
                              icon: Icons.location_on_outlined,
                              color: StiraTokens.stiraViolet,
                              options: const ['Bedroom', 'Car', 'Office', 'Bathroom', 'Other'],
                              selected: _location,
                              onSelect: (val) {
                                setState(() => _location = val);
                                Future.delayed(const Duration(milliseconds: 300), _next);
                              },
                            ),
                            _SelectionPage(
                              stepLabel: 'STEP 2 OF 3',
                              title: 'What was the\ndominant emotion?',
                              icon: Icons.favorite_border,
                              color: StiraTokens.stiraPink,
                              options: const ['Stressed', 'Lonely', 'Bored', 'Angry', 'Tired', 'Other'],
                              selected: _emotion,
                              onSelect: (val) {
                                setState(() => _emotion = val);
                                Future.delayed(const Duration(milliseconds: 300), _next);
                              },
                            ),
                            _SelectionPage(
                              stepLabel: 'STEP 3 OF 3',
                              title: 'What was the\nprimary trigger?',
                              icon: Icons.bolt_outlined,
                              color: StiraTokens.stiraAmber,
                              options: const ['Social Media', 'Stress', 'Boredom', 'Habit', 'Other'],
                              selected: _trigger,
                              onSelect: (val) {
                                setState(() => _trigger = val);
                                Future.delayed(const Duration(milliseconds: 300), _next);
                              },
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Intro Page ─────────────────────────────────────────────────────────────

class _IntroPage extends StatelessWidget {
  final VoidCallback onNext;
  const _IntroPage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StiraTokens.stiraTeal.withValues(alpha: 0.12),
              border: Border.all(color: StiraTokens.stiraTeal.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.analytics_outlined,
                color: StiraTokens.stiraTeal, size: 28),
          ),
          const SizedBox(height: 28),
          Text(
            'A slip is a data\npoint, not a\ncharacter flaw.',
            style: GoogleFonts.syne(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: StiraTokens.stiraWhite,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Let's look at what your nervous system was reacting to so Stira can forecast this better next time.",
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: StiraTokens.stiraMuted,
              height: 1.6,
            ),
          ),
          const Spacer(),
          StiraGlassCard(
            accentColor: StiraTokens.stiraTeal,
            fullWidth: true,
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    color: StiraTokens.stiraTeal, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your streak will reset. Your progress data is preserved.',
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: StiraTokens.stiraWhite, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [StiraTokens.stiraTeal, StiraTokens.stiraViolet],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: StiraTokens.stiraTeal.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Begin Autopsy',
                style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Selection Page ─────────────────────────────────────────────────────────

class _SelectionPage extends StatelessWidget {
  final String stepLabel;
  final String title;
  final IconData icon;
  final Color color;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  final bool isLast;

  const _SelectionPage({
    required this.stepLabel,
    required this.title,
    required this.icon,
    required this.color,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                stepLabel,
                style: GoogleFonts.dmMono(
                  fontSize: 11,
                  color: color,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.syne(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: StiraTokens.stiraWhite,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final t = options[i];
                final isSelected = selected == t;
                return GestureDetector(
                  onTap: () => onSelect(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.18)
                          : StiraTokens.stiraGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : StiraTokens.stiraGlassBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? color : StiraTokens.stiraWhite,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: color, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLast)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Your baseline is preserved. Stira understands you better now.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: StiraTokens.stiraMuted,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Completion View ────────────────────────────────────────────────────────

class _CompletedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [StiraTokens.stiraTeal, StiraTokens.stiraViolet, StiraTokens.stiraTeal],
                ),
                boxShadow: [
                  BoxShadow(
                    color: StiraTokens.stiraTeal.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.restart_alt_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 28),
            Text(
              'Day 1.',
              style: GoogleFonts.syne(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: StiraTokens.stiraTeal,
                shadows: [
                  Shadow(
                    color: StiraTokens.stiraTeal.withValues(alpha: 0.6),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Every recovery starts\nwith this exact moment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: StiraTokens.stiraMuted,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
