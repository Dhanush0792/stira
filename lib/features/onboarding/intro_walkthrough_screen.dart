import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../services/local_storage.dart';
import 'welcome_screen.dart';

// ─── Intro Walkthrough Screen ─────────────────────────────────────────────────
// 3 simple, plain-English slides that explain the app before login.
// Uses warm, relatable language — no jargon.
// ─────────────────────────────────────────────────────────────────────────────

class IntroWalkthroughScreen extends StatefulWidget {
  const IntroWalkthroughScreen({super.key});

  @override
  State<IntroWalkthroughScreen> createState() => _IntroWalkthroughScreenState();
}

class _IntroWalkthroughScreenState extends State<IntroWalkthroughScreen>
    with TickerProviderStateMixin {
  int _currentSlide = 0;
  late AnimationController _slideCtrl;
  late Animation<double> _fade;

  final List<_Slide> _slides = const [
    _Slide(
      icon: '🛡️',
      accentColor: Color(0xFF1ECFB3),
      title: 'Your data stays with you',
      body:
          'Everything you write in Stira — your notes, moods, and check-ins — is saved only on your phone. Nothing is shared with anyone.',
    ),
    _Slide(
      icon: '🔔',
      accentColor: Color(0xFFB06BFF),
      title: 'We warn you before tough moments',
      body:
          'Stira learns your patterns and sends you a gentle reminder before you usually struggle most — so you can prepare instead of react.',
    ),
    _Slide(
      icon: '💪',
      accentColor: Color(0xFFE84393),
      title: 'Small tools, big difference',
      body:
          'Breathing exercises, a private journal, and simple check-ins. Every little thing you do builds a stronger habit over time.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fade = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _next() async {
    if (_currentSlide < _slides.length - 1) {
      await _slideCtrl.reverse();
      setState(() => _currentSlide++);
      _slideCtrl.forward();
    } else {
      await StorageService().setHasSeenIntro();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _skip() async {
    await StorageService().setHasSeenIntro();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentSlide];
    final isLast = _currentSlide == _slides.length - 1;

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Accent glow
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.1),
                radius: 1.0,
                colors: [
                  slide.accentColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 24),
                    child: GestureDetector(
                      onTap: _skip,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.dmSans(
                          color: StiraTokens.stiraMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Icon
                FadeTransition(
                  opacity: _fade,
                  child: Text(
                    slide.icon,
                    style: const TextStyle(fontSize: 72),
                  ),
                ),

                const SizedBox(height: 40),

                // Text content
                FadeTransition(
                  opacity: _fade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.syne(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: StiraTokens.stiraWhite,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            color: StiraTokens.stiraMuted,
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _currentSlide;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: active
                            ? slide.accentColor
                            : StiraTokens.stiraMuted.withValues(alpha: 0.3),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // Next / Login button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slide.accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isLast ? 'Create my account' : 'Next',
                        style: GoogleFonts.syne(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final String icon;
  final Color accentColor;
  final String title;
  final String body;
  const _Slide({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.body,
  });
}
