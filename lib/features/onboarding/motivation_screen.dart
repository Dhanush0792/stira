import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../services/local_storage.dart';
import 'intro_walkthrough_screen.dart';

// ─── Motivation Screen ────────────────────────────────────────────────────────
// First screen users see. Big motivational message + "Get Started" button.
// Routes to IntroWalkthroughScreen (onboarding slides).
// ─────────────────────────────────────────────────────────────────────────────

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    await StorageService().setHasSeenIntro(); // mark so we skip motivation next time
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const IntroWalkthroughScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated background glow
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.1,
                  colors: [
                    StiraTokens.stiraViolet.withValues(alpha: 0.18 * _pulse.value),
                    StiraTokens.stiraPink.withValues(alpha: 0.08 * _pulse.value),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo / Icon
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => Container(
                        height: 120,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: StiraTokens.stiraPink
                                  .withValues(alpha: 0.15 * _pulse.value),
                              blurRadius: 40 * _pulse.value,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icon/stira_logo_showcase.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Headline
                    Text(
                      'You can do this.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.syne(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: StiraTokens.stiraWhite,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sub-headline
                    Text(
                      'Every day you choose to try is a win.\nStira is here to help you stay strong,\none step at a time.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: StiraTokens.stiraMuted,
                        height: 1.6,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Get Started Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _onGetStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StiraTokens.stiraPink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.syne(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
