import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/stira_tokens.dart';
import '../../../widgets/stira_glass_card.dart';
import '../../../widgets/stira_card_label.dart';
import '../../../widgets/stira_primary_button.dart';
import '../../../core/stira_routes.dart';
import '../../../core/stira_stagger.dart';
import '../../reset/reset_protocol.dart';
import '../../reflection/future_you_screen.dart';
import '../../vault/vault_screen.dart';
import '../../bond/bond_mode_screen.dart';
import '../../tools/habit_engine_screen.dart';
import '../../tools/breathing_reset_screen.dart';
import '../../tools/challenges/challenge_hub_screen.dart';
import '../../../services/stira_haptic_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/tour/stira_info_icon.dart';
import '../../../services/stira_bond_service.dart';

/// Tab 2 — Intervention Toolkit (Stira v2 — migrated to StiraTokens)
class ToolsTab extends StatefulWidget {
  const ToolsTab({super.key});

  @override
  State<ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends State<ToolsTab>
    with TickerProviderStateMixin, StiraStaggerMixin {
  late AnimationController _breathCtrl;
  String _breathPhase = 'inhale l';

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _breathCtrl.addListener(() {
      final t = _breathCtrl.value;
      String newPhase = 'inhale l';
      if (t < (1 / 6)) {
        newPhase = 'inhale l';
      } else if (t < (2 / 6)) {
        newPhase = 'hold';
      } else if (t < (3 / 6)) {
        newPhase = 'exhale r';
      } else if (t < (4 / 6)) {
        newPhase = 'inhale r';
      } else if (t < (5 / 6)) {
        newPhase = 'hold';
      } else {
        newPhase = 'exhale l';
      }
      if (newPhase != _breathPhase && mounted) {
        setState(() => _breathPhase = newPhase);
      }
    });
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  double get _breathScale {
    final t = _breathCtrl.value;
    if (t < (1 / 6)) {
      return 0.65 + (t / (1 / 6)) * 0.35;
    } else if (t < (2 / 6)) {
      return 1.0;
    } else if (t < (3 / 6)) {
      return 1.0 - ((t - (2 / 6)) / (1 / 6)) * 0.35;
    } else if (t < (4 / 6)) {
      return 0.65 + ((t - (3 / 6)) / (1 / 6)) * 0.35;
    } else if (t < (5 / 6)) {
      return 1.0;
    } else {
      return 1.0 - ((t - (5 / 6)) / (1 / 6)) * 0.35;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StiraTokens.stiraBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Violet center glow per spec (tools tab)
          Container(decoration: StiraTokens.bgVioletCenterGlow),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  staggerItem(0, Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Intervention Tools',
                          style: StiraTokens.displayTitle
                              .copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        'Use these when the urge arrives.',
                        style: StiraTokens.bodyText,
                      ),
                    ]
                  )),
                  const SizedBox(height: 24),

                  // ── RESET PROTOCOL (teal) ─────────────────────────
                  staggerItem(1, StiraGlassCard(
                    accentColor: StiraTokens.stiraTeal,
                    fullWidth: true,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(children: [
                                  _iconCircle('🫁', StiraTokens.stiraTeal),
                                  const SizedBox(width: 8),
                                  const StiraCardLabel('RESET PROTOCOL'),
                                  const Spacer(),
                                  const StiraInfoIcon(featureId: 'breathing_reset'),
                                ]),
                              const SizedBox(height: 6),
                              Text(
                                'A guided breathing session to break the autopilot before it takes over.',
                                style: StiraTokens.bodyText,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 72,
                          child: StiraPrimaryButton(
                            label: 'Start',
                            color: StiraTokens.stiraTeal,
                            onTap: () => Navigator.of(context).pushStira(const BreathingResetScreen()),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // ── 4-4-4 BREATHING (violet) ──────────────────────
                  staggerItem(2, StiraGlassCard(
                    accentColor: StiraTokens.stiraViolet,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          _iconCircle('🌬️', StiraTokens.stiraViolet),
                          const SizedBox(width: 10),
                          Text('Nadi Shodhana',
                              style: GoogleFonts.syne(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: StiraTokens.stiraViolet)),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'Ancient alternate nostril breathing to calm urges and stress instantly.',
                          style: StiraTokens.bodyText,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: AnimatedBuilder(
                            animation: _breathCtrl,
                            builder: (_, __) {
                              final scale = _breathScale;
                              return Column(
                                children: [
                                  Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: StiraTokens.stiraTealSoft,
                                        border: Border.all(
                                          color: StiraTokens.stiraTeal
                                              .withValues(alpha: 0.5),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: StiraTokens.stiraTeal
                                                .withValues(alpha: scale * 0.35),
                                            blurRadius: 24 * scale,
                                            spreadRadius: 4 * scale,
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _breathPhase.contains('inhale')
                                            ? '↑'
                                            : _breathPhase == 'hold'
                                                ? '—'
                                                : '↓',
                                        style: GoogleFonts.syne(
                                          fontSize: 20,
                                          color: StiraTokens.stiraTeal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _breathPhase.toUpperCase(),
                                    style: GoogleFonts.dmMono(
                                      fontSize: 9,
                                      letterSpacing: 2.5,
                                      color: StiraTokens.stiraTeal,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // ── VAULT MESSAGE (amber) ─────────────────────────
                  staggerItem(3, StiraGlassCard(
                    accentColor: StiraTokens.stiraAmber,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Row(children: [
                            _iconCircle('🗝️', StiraTokens.stiraAmber),
                            const SizedBox(width: 10),
                            Text('The Vault',
                                style: GoogleFonts.syne(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: StiraTokens.stiraAmber)),
                            const Spacer(),
                            const StiraInfoIcon(featureId: 'vault'),
                          ]),
                        const SizedBox(height: 8),
                        // Section 6A copy fix
                        Text(
                          'Write to yourself from a place of strength. You\'ll read it when you need it most.',
                          style: StiraTokens.bodyText,
                        ),
                        const SizedBox(height: 12),
                        StiraPrimaryButton(
                          label: 'Open Vault',
                          color: StiraTokens.stiraAmber,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VaultScreen())),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // ── BOND MODE (violet) ────────────────────────────
                  staggerItem(4, Consumer(
                    builder: (context, ref, child) {
                      final bondAsync = ref.watch(bondStatusProvider);
                      final bondData = bondAsync.value;
                      final partnerUid = bondData?['bond_partner_uid'] as String?;
                      
                      String? partnerName;
                      if (partnerUid != null && partnerUid.isNotEmpty) {
                        final partnerAsync = ref.watch(partnerDataProvider(partnerUid));
                        partnerName = partnerAsync.value?['name'] as String?;
                      }

                      final isBonded = partnerName != null && partnerName.isNotEmpty;

                      return StiraGlassCard(
                        accentColor: StiraTokens.stiraViolet,
                        fullWidth: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              _iconCircle('🤝', StiraTokens.stiraViolet),
                              const SizedBox(width: 10),
                              Text('Bond Mode',
                                  style: GoogleFonts.syne(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: StiraTokens.stiraViolet)),
                              const Spacer(),
                              const StiraInfoIcon(featureId: 'bond_mode'),
                            ]),
                            const SizedBox(height: 8),
                            Text(
                              isBonded 
                                  ? 'Bonded with $partnerName. Private 2-person accountability.'
                                  : 'Connect with one trusted person. Private 2-person accountability.',
                              style: StiraTokens.bodyText,
                            ),
                            const SizedBox(height: 12),
                            StiraPrimaryButton(
                              label: isBonded ? 'View Bond' : 'Set Up Bond',
                              color: StiraTokens.stiraViolet,
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BondModeScreen())),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
                  const SizedBox(height: 12),
                  
                  // ── REPLACEMENT HABITS (violet) ───────────────────
                  staggerItem(5, StiraGlassCard(
                    accentColor: StiraTokens.stiraViolet,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          _iconCircle('🔄', StiraTokens.stiraViolet),
                          const SizedBox(width: 10),
                          Text('Replacement Habits',
                              style: GoogleFonts.syne(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: StiraTokens.stiraViolet)),
                          const Spacer(),
                          const StiraInfoIcon(featureId: 'replacement_habits'),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'Top habits based on what you need right now.',
                          style: StiraTokens.bodyText,
                        ),
                        const SizedBox(height: 12),
                        ...[
                          '🚿  Cold Water Cue',
                          '🚶  Walk Redirect',
                          '💪  10 Pushups',
                        ].map((h) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: StiraTokens.stiraViolet
                                      .withValues(alpha: 0.1),
                                  border: Border.all(
                                      color: StiraTokens.stiraViolet
                                          .withValues(alpha: 0.2)),
                                ),
                                child: Text(h,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: StiraTokens.stiraWhite)),
                              ),
                            )),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // ── DISTRACTION CHALLENGES (pink) ───────────────────
                  staggerItem(6, StiraGlassCard(
                    accentColor: StiraTokens.stiraPink,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          _iconCircle('🧩', StiraTokens.stiraPink),
                          const SizedBox(width: 10),
                          Text('Distraction Challenges',
                              style: GoogleFonts.syne(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: StiraTokens.stiraPink)),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'Engage your prefrontal cortex. Override the craving with math or trivia.',
                          style: StiraTokens.bodyText,
                        ),
                        const SizedBox(height: 12),
                        StiraPrimaryButton(
                          label: 'Start Challenge',
                          color: StiraTokens.stiraPink,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChallengeHubScreen())),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // ── SOS HEARTBEAT (amber) ─────────────────────────
                  staggerItem(7, StiraGlassCard(
                     accentColor: StiraTokens.stiraAmber,
                     fullWidth: true,
                     child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(children: [
                              _iconCircle('💗', StiraTokens.stiraAmber),
                              const SizedBox(width: 10),
                              Text('SOS Heartbeat',
                                 style: GoogleFonts.syne(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: StiraTokens.stiraAmber)),
                           ]),
                           const SizedBox(height: 8),
                           Text(
                              'A physical interrupt that says: "You are not your autopilot." Trigger it to snap back to reality.',
                              style: StiraTokens.bodyText,
                           ),
                           const SizedBox(height: 12),
                           StiraPrimaryButton(
                              label: 'Trigger Heartbeat',
                              color: StiraTokens.stiraAmber,
                              onTap: () {
                                 StiraHapticService().triggerSOSHeartbeat();
                              },
                           ),
                        ],
                     ),
                  )),
                  const SizedBox(height: 12),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconCircle(String emoji, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 14)),
    );
  }
}
