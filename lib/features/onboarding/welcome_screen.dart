import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_orb.dart';
import '../../services/stira_auth_service.dart';
import '../../core/auth_wrapper.dart';

// ─── Welcome / Authentication Screen ─────────────────────────────────────────
//
// This is the app's authentication gate.
// Unauthenticated users land here and have two choices:
//   1. Continue with Google  — creates/restores a persistent account
//   2. Continue as Guest     — local-only mode, no cloud sync or Bond Mode
//
// Design language: Aurora Glass Calm Interface System
// ─────────────────────────────────────────────────────────────────────────────

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ─────────────────────────────────────────────────
  late final AnimationController _staggerCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _glowCtrl;

  late final Animation<double> _slideAnim;
  late final Animation<double> _glowAnim;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _slideAnim = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.1, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _glowAnim = Tween<double>(begin: 0.08, end: 0.18).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── Stagger fade helper ───────────────────────────────────────────────────

  Widget _fade(int index, Widget child) {
    final start = (index * 0.12).clamp(0.0, 0.8);
    final end = (start + 0.35).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
      child: child,
    );
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await StiraAuthService().signInWithGoogle();

    if (!mounted) return;

    if (result.success) {
      // AuthWrapper will handle routing based on onboarding state.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } else if (!result.wasCancelled) {
      setState(() {
        _errorMessage = result.errorMessage;
        _isLoading = false;
      });
    } else {
      // User cancelled picker — just reset.
      setState(() => _isLoading = false);
    }
  }

  // ── Guest Mode ────────────────────────────────────────────────────────────

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await StiraAuthService().continueAsGuest();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
      (route) => false,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient ──────────────────────────────────────────
          const _AuroraBackground(),

          // ── Animated top glow ────────────────────────────────────────────
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.75),
                  radius: 0.9,
                  colors: [
                    StiraTokens.stiraPink.withValues(alpha: _glowAnim.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Orb ─────────────────────────────────────────────────
                  _fade(
                    0,
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, child) => Transform.scale(
                        scale: 0.94 + (_pulseCtrl.value * 0.12),
                        child: child,
                      ),
                      child: const StiraOrb(size: 88, intensity: 0.6),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Headline ─────────────────────────────────────────────
                  _fade(
                    1,
                    AnimatedBuilder(
                      animation: _slideAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _slideAnim.value),
                        child: child,
                      ),
                      child: Text(
                        "You're not broken.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.syne(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: StiraTokens.stiraWhite,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Subheadline ──────────────────────────────────────────
                  _fade(
                    2,
                    Text(
                      "You're building stability.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: StiraTokens.stiraMuted,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Error message ────────────────────────────────────────
                  if (_errorMessage != null) ...[
                    _fade(
                      3,
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: StiraTokens.stiraPink.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: StiraTokens.stiraPink.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: StiraTokens.stiraPink,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Continue with Google ─────────────────────────────────
                  _fade(
                    3,
                    _GoogleSignInButton(
                      isLoading: _isLoading,
                      onTap: _isLoading ? null : _signInWithGoogle,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Continue as Guest ────────────────────────────────────
                  _fade(
                    4,
                    _GuestButton(
                      isLoading: _isLoading,
                      onTap: _isLoading ? null : _continueAsGuest,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Privacy links ────────────────────────────────────────
                  _fade(
                    5,
                    _PrivacyFooter(),
                  ),

                  const SizedBox(height: 20),

                  // ── Badge ────────────────────────────────────────────────
                  _fade(
                    6,
                    Text(
                      'PRIVATE · ENCRYPTED · YOURS',
                      style: GoogleFonts.dmMono(
                        color: StiraTokens.stiraMuted.withValues(alpha: 0.5),
                        fontSize: 8.5,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Aurora Background ─────────────────────────────────────────────────────────

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [StiraTokens.stiraBg2, StiraTokens.stiraBg],
        ),
      ),
    );
  }
}

// ─── Google Sign-In Button ─────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _GoogleSignInButton({required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                StiraTokens.stiraPink.withValues(alpha: 0.15),
                StiraTokens.stiraPink.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: StiraTokens.stiraPink.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: StiraTokens.stiraPink.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google "G" rendered cleanly with a colored icon
                    _GoogleGIcon(),
                    const SizedBox(width: 10),
                    Text(
                      'Continue with Google',
                      style: GoogleFonts.dmSans(
                        color: StiraTokens.stiraWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GoogleGIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4285F4),
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ─── Guest Button ──────────────────────────────────────────────────────────────

class _GuestButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _GuestButton({required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: StiraTokens.stiraGlass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StiraTokens.stiraGlassBorder),
          ),
          child: Center(
            child: Text(
              'Continue as Guest',
              style: GoogleFonts.dmSans(
                color: StiraTokens.stiraMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Privacy Footer ────────────────────────────────────────────────────────────

class _PrivacyFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.dmSans(
          fontSize: 11,
          color: StiraTokens.stiraMuted.withValues(alpha: 0.6),
          height: 1.6,
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Privacy Policy',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: StiraTokens.stiraTeal.withValues(alpha: 0.8),
              decoration: TextDecoration.underline,
              decorationColor: StiraTokens.stiraTeal.withValues(alpha: 0.4),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Privacy Policy URL — update before publishing.
                // Could use url_launcher here when the URL is ready.
                debugPrint('Privacy Policy tapped');
              },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Terms of Service',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: StiraTokens.stiraTeal.withValues(alpha: 0.8),
              decoration: TextDecoration.underline,
              decorationColor: StiraTokens.stiraTeal.withValues(alpha: 0.4),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                debugPrint('Terms of Service tapped');
              },
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
