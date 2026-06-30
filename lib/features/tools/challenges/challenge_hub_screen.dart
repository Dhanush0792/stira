import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/stira_tokens.dart';
import '../../../widgets/stira_glass_card.dart';
import '../../../widgets/stira_primary_button.dart';
import 'math_sprint_screen.dart';
import 'stroop_challenge_screen.dart';
import 'pattern_recall_screen.dart';

class ChallengeHubScreen extends StatelessWidget {
  const ChallengeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: StiraTokens.stiraWhite, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Challenge Hub',
          style: GoogleFonts.syne(
            color: StiraTokens.stiraWhite,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(decoration: StiraTokens.bgVioletCenterGlow),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildChallengeCard(
                  context,
                  title: 'Math Sprint',
                  description: '10 rapid-fire math problems. Engage your prefrontal cortex.',
                  icon: '🧮',
                  color: StiraTokens.stiraTeal,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MathSprintScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _buildChallengeCard(
                  context,
                  title: 'Pattern Recall',
                  description: 'Memorize and match the symbol sequences.',
                  icon: '🧩',
                  color: StiraTokens.stiraViolet,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PatternRecallScreen()),
                  ),
                  isLocked: false,
                ),
                const SizedBox(height: 16),
                _buildChallengeCard(
                  context,
                  title: 'Color Clash',
                  description: 'The Stroop test. Identify colors, ignore words.',
                  icon: '🎨',
                  color: StiraTokens.stiraPink,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ColorClashScreen()),
                  ),
                  isLocked: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context, {
    required String title,
    required String description,
    required String icon,
    required Color color,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return StiraGlassCard(
      accentColor: isLocked ? StiraTokens.stiraMuted : color,
      fullWidth: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.syne(
                    color: isLocked ? StiraTokens.stiraMuted : StiraTokens.stiraWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isLocked)
                const Icon(Icons.lock_outline, color: StiraTokens.stiraMuted, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.dmSans(
              color: StiraTokens.stiraMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          StiraPrimaryButton(
            label: isLocked ? 'Coming Soon' : 'Start',
            color: isLocked ? StiraTokens.stiraMuted : color,
            onTap: isLocked ? null : onTap,
          ),
        ],
      ),
    );
  }
}
