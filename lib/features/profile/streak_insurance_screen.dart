import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../services/auth_service.dart';

class StreakInsuranceScreen extends ConsumerWidget {
  const StreakInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider).value;
    final shieldCount = userData?['streak_insurance_available'] as int? ?? 0;
    final currentStreak = userData?['current_streak'] as int? ?? 0;

    int nextMilestone = 14;
    if (currentStreak >= 14) nextMilestone = 30;
    if (currentStreak >= 30) nextMilestone = 60;
    if (currentStreak >= 60) nextMilestone = -1; // Max earned

    final  daysToNext = nextMilestone != -1 ? nextMilestone - currentStreak : 0;
    final double progress = nextMilestone != -1 ? (currentStreak / nextMilestone).clamp(0.0, 1.0) : 1.0;

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          Container(decoration: StiraTokens.bgVioletCenterGlow),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StiraTokens.stiraWhite.withOpacity(0.05),
                            border: Border.all(color: StiraTokens.stiraWhite.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.arrow_back, size: 16, color: StiraTokens.stiraWhite),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Streak Insurance',
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: StiraTokens.stiraWhite,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Shield Status
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: shieldCount > 0 ? StiraTokens.stiraViolet.withOpacity(0.15) : StiraTokens.stiraGlass,
                              border: Border.all(
                                color: shieldCount > 0 ? StiraTokens.stiraViolet : StiraTokens.stiraGlassBorder,
                                width: 2,
                              ),
                              boxShadow: shieldCount > 0
                                  ? [BoxShadow(color: StiraTokens.stiraViolet.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              shieldCount > 0 ? '🛡️' : '🔒',
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            shieldCount > 0 ? '$shieldCount Shield(s) Active' : 'No Shields Available',
                            style: GoogleFonts.syne(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: StiraTokens.stiraWhite,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            shieldCount > 0
                                ? 'Your next relapse will be logged, but your streak will stay intact.'
                                : 'You are currently unprotected. Maintain your streak to earn shields.',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: StiraTokens.stiraMuted,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Progress to Next Shield
                        if (nextMilestone != -1) ...[
                          Text(
                            'NEXT SHIELD EARNED IN',
                            style: GoogleFonts.dmMono(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: StiraTokens.stiraViolet,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          StiraGlassCard(
                            accentColor: StiraTokens.stiraViolet,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$daysToNext Days',
                                      style: GoogleFonts.syne(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: StiraTokens.stiraWhite,
                                      ),
                                    ),
                                    Text(
                                      'Day $nextMilestone',
                                      style: GoogleFonts.dmMono(
                                        fontSize: 12,
                                        color: StiraTokens.stiraMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: StiraTokens.stiraWhite.withOpacity(0.1),
                                  valueColor: const AlwaysStoppedAnimation<Color>(StiraTokens.stiraViolet),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                           StiraGlassCard(
                             accentColor: StiraTokens.stiraViolet,
                             child: Row(
                               children: [
                                 const Icon(Icons.military_tech, color: StiraTokens.stiraViolet, size: 32),
                                 const SizedBox(width: 16),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         'Maximum Shields Earned',
                                         style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.bold, color: StiraTokens.stiraWhite),
                                       ),
                                       Text(
                                          'You have reached 60+ days clean. Exceptional work.',
                                          style: GoogleFonts.dmSans(fontSize: 13, color: StiraTokens.stiraMuted),
                                       )
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                           ),
                        ],

                        const SizedBox(height: 32),
                        
                        Text(
                          'HOW IT WORKS',
                          style: GoogleFonts.dmMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: StiraTokens.stiraMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Milestones', 'Earn 1 shield exactly at Day 14, Day 30, and Day 60 of your clean streak.'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Usage', 'When logging a relapse, you can choose to use a shield. Your relapse is still recorded to improve Stira\'s intelligence, but your streak counter is not reset.'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Purpose', 'Recovery isn\'t perfect. A single mistake shouldn\'t erase weeks of rewiring. The shield prevents the "What the hell" effect that leads to binges.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Icon(Icons.check_circle_outline, size: 16, color: StiraTokens.stiraViolet),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: StiraTokens.stiraWhite)),
              const SizedBox(height: 4),
              Text(desc, style: GoogleFonts.dmSans(fontSize: 13, color: StiraTokens.stiraMuted, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
