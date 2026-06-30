import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_led_metric.dart';
import '../../widgets/stira_card_label.dart';
import '../../services/stira_bond_service.dart';
import '../../services/stira_auth_service.dart';
import '../../core/tour/stira_info_icon.dart';

class BondActiveScreen extends ConsumerWidget {
  final String partnerUid;
  final Map<String, dynamic> userData;

  const BondActiveScreen({
    super.key,
    required this.partnerUid,
    required this.userData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerAsync = ref.watch(partnerDataProvider(partnerUid));
    final shareLevel = userData['bond_share_level'] ?? 'streak_only';

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
                      Row(
                        children: [
                          Text(
                            'Bond Active',
                            style: GoogleFonts.syne(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: StiraTokens.stiraWhite,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const StiraInfoIcon(featureId: 'bond_mode'),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: StiraTokens.stiraMuted, size: 20),
                        onPressed: () => _showSettings(context),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: partnerAsync.when(
                    data: (partnerData) {
                      if (partnerData == null) {
                        return const Center(child: Text('Partner data unavailable', style: TextStyle(color: Colors.white)));
                      }

                      final name = partnerData['name'] ?? 'Partner';
                      final streak = partnerData['current_streak'] ?? 0;
                      final partnerShareLevel = partnerData['bond_share_level'] ?? 'streak_only';
                      final intensity = partnerData['current_urge_level'] ?? 0;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          children: [
                            // Partner Avatar & Name
                            _buildPartnerHeader(name),
                            const SizedBox(height: 32),

                            // Shared Stats
                            Row(
                              children: [
                                Expanded(
                                  child: StiraGlassCard(
                                    accentColor: StiraTokens.stiraViolet,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        StiraLedMetric(
                                          value: '$streak',
                                          color: StiraTokens.stiraViolet,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 4),
                                        const StiraCardLabel('PARTNER STREAK'),
                                      ],
                                    ),
                                  ),
                                ),
                                if (partnerShareLevel != 'streak_only') ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: StiraGlassCard(
                                      accentColor: intensity >= 7 ? StiraTokens.stiraPink : StiraTokens.stiraTeal,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          StiraLedMetric(
                                            value: '$intensity',
                                            color: intensity >= 7 ? StiraTokens.stiraPink : StiraTokens.stiraTeal,
                                            size: 24,
                                          ),
                                          const SizedBox(height: 4),
                                          const StiraCardLabel('URGE LEVEL'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Encouragement Section
                            StiraGlassCard(
                              accentColor: StiraTokens.stiraWhite.withOpacity(0.1),
                              fullWidth: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SEND ENCOURAGEMENT',
                                    style: GoogleFonts.dmMono(
                                      fontSize: 10,
                                      color: StiraTokens.stiraMuted,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _EncouragementBtn(
                                        emoji: '🧘',
                                        label: 'Calm',
                                        color: StiraTokens.stiraTeal,
                                        onTap: () => _sendSignal(context, 'calm'),
                                      ),
                                      const SizedBox(width: 12),
                                      _EncouragementBtn(
                                        emoji: '⚡',
                                        label: 'Strength',
                                        color: StiraTokens.stiraViolet,
                                        onTap: () => _sendSignal(context, 'strength'),
                                      ),
                                      const SizedBox(width: 12),
                                      _EncouragementBtn(
                                        emoji: '❤️',
                                        label: 'Love',
                                        color: StiraTokens.stiraPink,
                                        onTap: () => _sendSignal(context, 'love'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Privacy Notice
                            Text(
                              'You are sharing: \${_shareLevelLabel(shareLevel)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: StiraTokens.stiraMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: StiraTokens.stiraViolet)),
                    error: (err, _) => Center(child: Text('Error loading partner data: $err', style: const TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerHeader(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [StiraTokens.stiraViolet, StiraTokens.stiraPink],
            ),
            boxShadow: [
              BoxShadow(
                color: StiraTokens.stiraViolet.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: StiraTokens.stiraWhite,
          ),
        ),
        Text(
          'Bond Partner',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: StiraTokens.stiraMuted,
          ),
        ),
      ],
    );
  }

  String _shareLevelLabel(String level) {
    switch (level) {
      case 'streak_only': return 'Streak Only';
      case 'streak_intensity': return 'Streak + Urge Level';
      case 'full_insights': return 'Full Insights';
      default: return 'Streak Only';
    }
  }

  void _sendSignal(BuildContext context, String type) {
    // In a real app, this would trigger an FCM push to the partner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent \${type.toUpperCase()} signal to partner!')),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: StiraTokens.stiraBg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bond Settings',
                style: GoogleFonts.syne(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: StiraTokens.stiraWhite,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.visibility_outlined, color: StiraTokens.stiraWhite),
                title: Text('Change Sharing Level', style: GoogleFonts.dmSans(color: StiraTokens.stiraWhite)),
                onTap: () {
                  Navigator.pop(ctx);
                  // Implementation for changing share level would go here
                },
              ),
              ListTile(
                leading: const Icon(Icons.link_off, color: StiraTokens.stiraPink),
                title: Text('End Bond', style: GoogleFonts.dmSans(color: StiraTokens.stiraPink)),
                onTap: () async {
                  await StiraBondService().endBond(StiraAuthService().getCurrentUser()!.uid);
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _EncouragementBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EncouragementBtn({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.08),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
