import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_orb.dart';
import '../../services/local_storage.dart';
import '../../services/stira_auth_service.dart';
import '../navigation/main_navigation.dart';
import '../security/biometric_wall_screen.dart';
import 'welcome_screen.dart';
import 'intro_walkthrough_screen.dart';
import 'motivation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _navigated = false;
  late final AnimationController _orbFadeCtrl;
  late final Animation<double> _orbFadeAnim;
  
  late final AnimationController _textFadeCtrl;
  late final Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();
    _orbFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _orbFadeAnim = CurvedAnimation(parent: _orbFadeCtrl, curve: Curves.easeOut);
    
    _textFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFadeAnim = CurvedAnimation(parent: _textFadeCtrl, curve: Curves.easeOut);

    _startAnimations();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted || _navigated) return;
      _navigated = true;
      final storage = StorageService();

      // Check real Firebase auth state — don't trust stale Hive flags alone.
      // If no Firebase user is signed in (and not explicitly in guest mode),
      // always restart from the beginning of the onboarding flow.
      final firebaseUser = StiraAuthService().getCurrentUser();
      final isGuest = storage.isGuestMode;
      final isLoggedIn = firebaseUser != null || isGuest;

      late Widget nextScreen;

      if (!isLoggedIn) {
        // No signed-in user at all — always show the full onboarding flow.
        // Clear stale flags so the motivation + walkthrough play from the top.
        storage.resetIntroSeen().ignore();
        nextScreen = const MotivationScreen();
      } else if (!storage.onboardingCompleted) {
        // Signed in but hasn't finished onboarding (e.g. name not set).
        nextScreen = storage.hasSeenIntro
            ? const WelcomeScreen()
            : const MotivationScreen();
      } else {
        // Fully onboarded — go to app (behind biometric wall if enabled).
        nextScreen = storage.isBiometricEnabled
            ? const BiometricWallScreen()
            : const MainNavigation();
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  void _startAnimations() async {
    _orbFadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _textFadeCtrl.forward();
  }

  @override
  void dispose() {
    _orbFadeCtrl.dispose();
    _textFadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _orbFadeAnim,
              child: Image.asset(
                'assets/icon/stira_logo.png',
                width: 220,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _textFadeAnim,
              child: Text(
                'BEHAVIORAL INTELLIGENCE',
                style: GoogleFonts.dmMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.5,
                  color: StiraTokens.stiraMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
