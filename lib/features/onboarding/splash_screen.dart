import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_orb.dart';
import '../../services/local_storage.dart';
import '../navigation/main_navigation.dart';
import '../security/biometric_wall_screen.dart';
import 'welcome_screen.dart';

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

      final Widget nextScreen = storage.onboardingCompleted
          ? (storage.isBiometricEnabled
              ? const BiometricWallScreen()
              : const MainNavigation())
          : const WelcomeScreen();

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
              child: const StiraOrb(intensity: 0.6, size: 90),
            ),
            const SizedBox(height: 20),
            FadeTransition(
                opacity: _textFadeAnim,
                child: Column(
                  children: [
                    Text(
                      'stira',
                      style: GoogleFonts.syne(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: StiraTokens.stiraPink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'BEHAVIORAL INTELLIGENCE',
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 2.5,
                        color: StiraTokens.stiraMuted,
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
