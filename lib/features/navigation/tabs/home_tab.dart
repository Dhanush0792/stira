import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../theme/stira_tokens.dart';
import '../../../widgets/stira_glass_card.dart';
import '../../../widgets/stira_led_metric.dart';
import '../../../widgets/stira_card_label.dart';
import '../../../widgets/stira_primary_button.dart';
import '../../../widgets/stira_ghost_button.dart';
import '../../../widgets/stira_destructive_text.dart';
import '../../../widgets/stira_orb.dart';
import '../../../widgets/stira_milestone_overlay.dart';
import '../../../core/risk_engine.dart';
import '../../../core/intelligence_layer.dart';
import '../../../core/stira_routes.dart';
import '../../../core/stira_stagger.dart';
import '../../../services/local_storage.dart';
import '../../dashboard/checkin_flow.dart';
import '../../reflection/grounding_screen.dart';
import '../../reset/reset_protocol.dart';
import '../notifications_screen.dart';
import '../../../core/tour/stira_info_icon.dart';

/// Tab 0 — Home (Stira v2 redesign)
class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with TickerProviderStateMixin, StiraStaggerMixin {

  Timer? _minuteTimer;
  bool _notificationsGranted = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    // Check milestone on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final streak = ref.read(intelligenceProvider).streak;
      showMilestoneIfNeeded(context, streak);
    });
    
    // Update real-time streak counter every minute
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        _notificationsGranted = status.isGranted;
      });
    }
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    super.dispose();
  }

  Color _orbColorFromUrge(int urge) {
    final intensity = urge / 10;
    if (intensity <= 0.33) return StiraTokens.stiraTeal;
    if (intensity <= 0.66) return StiraTokens.stiraAmber;
    return StiraTokens.stiraPink;
  }

  String _orbLabel(int urge) {
    if (urge <= 3) return 'Low intensity';
    if (urge <= 6) return 'Moderate';
    return 'High — check in';
  }

  String _forecastLabel(StabilityState state) {
    if (state.forecastWindow == null) return 'Stable window';
    final risk = state.riskLevel;
    if (risk == RiskLevel.elevated || risk == RiskLevel.critical) {
      return 'High risk window';
    }
    if (risk == RiskLevel.moderate) return 'Moderate risk';
    return 'Low vulnerability';
  }

  String _forecastDetail(StabilityState state) {
    if (state.forecastWindow == null) {
      return 'Stira sees no high-risk window ahead. Stay consistent.';
    }
    final h = state.forecastWindow!.endTime.hour;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return 'Monitoring through $h12:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(intelligenceProvider);
    final storage = StorageService();

    // Ghost Mode
    if (state.isGhostMode) {
      return _GhostHome(ref: ref);
    }

    final logs = storage.getLogs();
    final latestUrge =
        logs.isNotEmpty ? ((logs.last['urge'] as int?) ?? 5) : 5;
    final orbIntensity = latestUrge / 10.0;
    final orbColor = _orbColorFromUrge(latestUrge);
    
    final streakDays = state.streak;
    final longestStreak = state.longestStreak;
    final streakStart = storage.streakStartTime;
    
    final now = DateTime.now();
    int sDays = streakDays;
    int sHours = 0;
    int sMins = 0;
    
    if (streakStart != null) {
      final diff = now.difference(streakStart);
      sDays = diff.inDays;
      sHours = diff.inHours % 24;
      sMins = diff.inMinutes % 60;
      if (sDays < 0) sDays = 0;
      if (sHours < 0) sHours = 0;
      if (sMins < 0) sMins = 0;
    }

    final stabilityScore = state.stabilityIndex;
    final forecastLbl = _forecastLabel(state);
    final forecastDtl = _forecastDetail(state);
    final forecastConfidenceStr = '${(state.forecastConfidence * 100).toInt()}%';

    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';
    // Bug Fix #1: Use Firebase Auth display name as fallback so '?' never shows
    final firebaseDisplayName = FirebaseAuth.instance.currentUser?.displayName;
    final profileName = (storage.getProfile()?['name'] as String?);
    final name = (profileName?.isNotEmpty == true ? profileName : firebaseDisplayName) ?? '';
    final greetingText =
        name.isNotEmpty ? '$greeting, $name.' : '$greeting.';

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayLabel = dayLabels[now.weekday - 1];

    return Container(
      color: StiraTokens.stiraBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Amber radial gradient
          Container(
            decoration: StiraTokens.bgAmberCenterGlow,
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Top Bar ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greetingText,
                              style: StiraTokens.displayTitle,
                            ),
                            Text(
                              '$dayLabel · Day ${sDays > 0 ? sDays : 1}'.toUpperCase(),
                              style: StiraTokens.captionMono,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (c) => const NotificationsScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [StiraTokens.stiraPink, StiraTokens.stiraViolet],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.syne(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── Orb Section ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushStira(const CheckInFlow());
                            },
                            child: StiraOrb(intensity: orbIntensity, size: 120),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: orbColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: orbColor.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              StiraCardLabel(
                                _orbLabel(latestUrge),
                                color: StiraTokens.stiraAmber,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Your state right now',
                                style: GoogleFonts.syne(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: StiraTokens.stiraWhite,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const StiraInfoIcon(featureId: 'orb'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ─── Cards Grid ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Streak Card
                            Expanded(
                              child: StiraGlassCard(
                                accentColor: StiraTokens.stiraPink,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const StiraCardLabel('CURRENT STREAK'),
                                        const StiraInfoIcon(featureId: 'streak'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        StiraLedMetric(
                                          value: '$sDays',
                                          unit: 'd',
                                          color: StiraTokens.stiraPink,
                                        ),
                                        const SizedBox(width: 4),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            '${sHours}h ${sMins}m',
                                            style: GoogleFonts.dmMono(
                                              fontSize: 13,
                                              color: StiraTokens.stiraPink.withValues(alpha: 0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Personal best: ${longestStreak}d',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: StiraTokens.stiraMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Stability Card
                            Expanded(
                              child: StiraGlassCard(
                                accentColor: StiraTokens.stiraTeal,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const StiraCardLabel('STABILITY SCORE'),
                                        const StiraInfoIcon(featureId: 'stability_score'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    StiraLedMetric(
                                      value: '$stabilityScore',
                                      unit: '%',
                                      color: StiraTokens.stiraTeal,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Up 6pts this week',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: StiraTokens.stiraMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 0.ms).slideY(begin: 0.15, duration: 400.ms),
                        const SizedBox(height: 14),

                        // Forecast Card (Full Width) — No lock icon per bug #06
                        StiraGlassCard(
                          accentColor: StiraTokens.stiraAmber,
                          fullWidth: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // FORECAST chip label (amber) — replaces lock icon
                              Row(
                                children: [
                                  const StiraCardLabel('FORECAST'),
                                  const SizedBox(width: 8),
                                  const StiraInfoIcon(featureId: 'forecast'),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: StiraTokens.stiraAmber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: StiraTokens.stiraAmber.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'NEXT 6H',
                                      style: GoogleFonts.dmMono(
                                        fontSize: 7,
                                        letterSpacing: 1,
                                        color: StiraTokens.stiraAmber,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$forecastConfidenceStr CONFIDENCE',
                                    style: GoogleFonts.dmMono(
                                      fontSize: 9,
                                      color: StiraTokens.stiraMuted,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                forecastLbl,
                                style: GoogleFonts.dmMono(
                                  fontSize: 15,
                                  color: StiraTokens.stiraAmber,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // 6-hour Risk Timeline Bar
                              Row(
                                children: List.generate(6, (i) {
                                  final targetH = (now.hour + i + 1) % 24;
                                  bool isAtRisk = false;
                                  if (state.forecastWindow != null) {
                                    final start = state.forecastWindow!.startTime.hour;
                                    final end = state.forecastWindow!.endTime.hour;
                                    if (start <= end) {
                                      isAtRisk = targetH >= start && targetH <= end;
                                    } else {
                                      isAtRisk = targetH >= start || targetH <= end;
                                    }
                                  }
                                  return Expanded(
                                    child: Container(
                                      height: 4,
                                      margin: EdgeInsets.only(right: i < 5 ? 4 : 0),
                                      decoration: BoxDecoration(
                                        color: isAtRisk 
                                            ? StiraTokens.stiraAmber 
                                            : StiraTokens.stiraTeal.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Now',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      color: StiraTokens.stiraMuted,
                                    ),
                                  ),
                                  Text(
                                    '+6h',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      color: StiraTokens.stiraMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                forecastDtl,
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: StiraTokens.stiraMuted,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 80.ms).slideY(begin: 0.15, duration: 400.ms),
                        const SizedBox(height: 24),

                        // Notifications Warning (if disabled locally OR at system level)
                        if (!storage.notificationsEnabled || !_notificationsGranted)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: StiraGlassCard(
                              accentColor: StiraTokens.stiraViolet,
                              fullWidth: true,
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications_paused_outlined, color: StiraTokens.stiraViolet, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notification Alerts Disabled',
                                          style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.bold, color: StiraTokens.stiraWhite),
                                        ),
                                        Text(
                                          'Stira needs notification access to deliver predictive risk alerts.',
                                          style: GoogleFonts.dmSans(fontSize: 11, color: StiraTokens.stiraMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => openAppSettings(),
                                    child: Text(
                                      'MANAGE',
                                      style: GoogleFonts.syne(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: StiraTokens.stiraViolet,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, duration: 400.ms),

                        // ─── Actions Row ─────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('YOUR ACTIONS', style: GoogleFonts.dmMono(fontSize: 10, color: StiraTokens.stiraMuted, letterSpacing: 1.5)),
                            const StiraInfoIcon(featureId: 'checkin'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StiraPrimaryButton(
                                label: 'Check-in',
                                color: StiraTokens.stiraPink,
                                onTap: () {
                                  Navigator.of(context).pushStira(const CheckInFlow());
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            StiraGhostButton(
                              label: 'Pause',
                              onTap: () {
                                Navigator.of(context).pushStira(const GroundingScreen());
                              },
                            ),
                            const SizedBox(width: 8),
                            StiraDestructiveText(
                              label: 'Reset',
                              onTap: () => _showResetConfirmation(context),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.15, duration: 400.ms),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: StiraTokens.stiraBg.withValues(alpha: 0.8),
      builder: (ctx) => AlertDialog(
        backgroundColor: StiraTokens.stiraBg2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: StiraTokens.stiraPink.withValues(alpha: 0.5))),
        title: Text('Initiate Reset Protocol?',
            style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: StiraTokens.stiraWhite)),
        content: Text(
          'This will guide you through an emergency intervention. Your streak will be preserved unless you confirm a relapse.',
          style: GoogleFonts.dmSans(fontSize: 13, color: StiraTokens.stiraMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.syne(color: StiraTokens.stiraMuted)),
          ),
          ElevatedButton(
            onPressed: () {
            Navigator.pop(ctx);
              Navigator.of(context).pushStira(const ResetProtocol());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StiraTokens.stiraPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Reset',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _GhostHome extends StatelessWidget {
  final WidgetRef ref;
  const _GhostHome({required this.ref});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final expiry = storage.ghostModeExpiry;
    final hours =
        expiry != null ? expiry.difference(DateTime.now()).inHours : 24;

    return Container(
      color: StiraTokens.stiraBg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.nights_stay_outlined,
                  size: 64, color: StiraTokens.stiraViolet.withValues(alpha: 0.5)),
              const SizedBox(height: 32),
              Text(
                'Anti-Relapse Binge Protocol Active',
                style: GoogleFonts.syne(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: StiraTokens.stiraWhite,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Intelligence layer suspended to prevent tracking anxiety.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: StiraTokens.stiraMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: StiraTokens.stiraGlass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: StiraTokens.stiraGlassBorder),
                ),
                child: Text(
                  'Ghost Mode active for $hours more hours',
                  style: GoogleFonts.dmMono(
                      fontSize: 10, color: StiraTokens.stiraViolet),
                ),
              ),
              const SizedBox(height: 64),
              StiraGhostButton(
                label: 'Disable Ghost Mode',
                onTap: () async {
                  await storage.deactivateGhostMode();
                  ref.read(intelligenceProvider.notifier).recompute();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ghost Mode disabled.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
