import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../services/local_storage.dart';
import '../../services/stira_auth_service.dart';
import '../dashboard/commitment_screen.dart';
import 'permissions_gate_screen.dart';

// ─── Insight Screen ───────────────────────────────────────────────────────────
//
// Shown after the 6-step OnboardingAssessment.
// Displays the user's detected patterns and then:
//   1. Saves assessment data to Hive (local).
//   2. Saves assessment data + marks onboarding_complete=true to Firestore.
//   3. Navigates to CommitmentScreen.
//
// This screen is only shown once per account (onboarding gate in AuthWrapper).
// ─────────────────────────────────────────────────────────────────────────────

class InsightScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const InsightScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final insights = [
      {
        'icon': Icons.lock_outline,
        'text': 'Your vulnerability window: ${data['window'] ?? "Late Night"}'
      },
      {
        'icon': Icons.lightbulb_outline,
        'text': 'Primary catalyst: ${data['trigger'] ?? "Acute Stress"}'
      },
      {
        'icon': Icons.shield_outlined,
        'text': 'Stability baseline: ${data['goal'] ?? "Calm presence"}'
      },
    ];

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StiraTokens.stiraViolet.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Here\u2019s what we see.',
                    style: GoogleFonts.syne(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: StiraTokens.stiraWhite,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your patterns, observed without judgment.',
                    style: GoogleFonts.dmSans(
                      color: StiraTokens.stiraMuted,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ...insights.map((ins) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: StiraGlassCard(
                          accentColor: StiraTokens.stiraViolet,
                          fullWidth: true,
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: StiraTokens.stiraViolet
                                      .withValues(alpha: 0.1),
                                  border: Border.all(
                                      color: StiraTokens.stiraViolet
                                          .withValues(alpha: 0.2)),
                                ),
                                child: Icon(
                                  ins['icon'] as IconData,
                                  color: StiraTokens.stiraViolet,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  ins['text'] as String,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: StiraTokens.stiraWhite,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'Awareness builds stability.',
                      style: GoogleFonts.dmMono(
                        color: StiraTokens.stiraMuted,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _SavePlanButton(assessmentData: data),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Save Plan Button ─────────────────────────────────────────────────────────

class _SavePlanButton extends StatefulWidget {
  final Map<String, dynamic> assessmentData;
  const _SavePlanButton({required this.assessmentData});

  @override
  State<_SavePlanButton> createState() => _SavePlanButtonState();
}

class _SavePlanButtonState extends State<_SavePlanButton> {
  bool _saving = false;

  Future<void> _saveAndContinue() async {
    setState(() => _saving = true);

    final storage = StorageService();
    final authService = StiraAuthService();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // 1. Save to Hive (always — works offline too).
    await storage.saveProfile(widget.assessmentData);
    await storage.setOnboardingCompleted();

    // 2. Save to Firestore + mark onboarding complete (best-effort, non-blocking).
    if (uid != null) {
      await authService.completeOnboarding(
        uid: uid,
        assessmentData: widget.assessmentData,
      );
    }

    if (!mounted) return;

    // 3. Navigate to CommitmentScreen, clearing the onboarding stack.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PermissionsGateScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StiraPrimaryButton(
      label: 'Save My Plan',
      color: StiraTokens.stiraViolet,
      isLoading: _saving,
      onTap: _saving ? null : _saveAndContinue,
    );
  }
}
