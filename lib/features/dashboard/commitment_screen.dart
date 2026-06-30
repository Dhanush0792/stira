import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../widgets/stira_orb.dart';
import '../navigation/main_navigation.dart';

class CommitmentScreen extends StatelessWidget {
  const CommitmentScreen({super.key});

  void _begin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigation(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StiraTokens.stiraViolet.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const StiraOrb(size: 80, intensity: 0.6),
                  const SizedBox(height: 48),
                  Text(
                    'Let\u2019s begin.',
                    style: GoogleFonts.syne(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: StiraTokens.stiraWhite,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Log your first check-in to establish your baseline.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: StiraTokens.stiraMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 64),
                  StiraGlassCard(
                    accentColor: StiraTokens.stiraViolet,
                    fullWidth: true,
                    child: Column(
                      children: [
                        Text(
                          'Your journey is private and secure.',
                          style: GoogleFonts.dmMono(
                            fontSize: 11,
                            color: StiraTokens.stiraViolet,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        StiraPrimaryButton(
                          label: 'Continue',
                          color: StiraTokens.stiraViolet,
                          onTap: () => _begin(context),
                        ),
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
}
