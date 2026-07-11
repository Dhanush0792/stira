import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/stira_auth_service.dart';
import '../services/local_storage.dart';
import '../features/navigation/main_navigation.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/name_input_screen.dart';
import '../features/profile/disguise_screens.dart';

// ─── Auth Wrapper ─────────────────────────────────────────────────────────────
//
// Tri-state router:
//
//   1. UNAUTHENTICATED (or guest): → WelcomeScreen
//   2. AUTHENTICATED + onboarding incomplete: → OnboardingAssessment
//   3. AUTHENTICATED + onboarding complete:   → MainNavigation
//
// Wrapped in [ShadowWrapper] to support Shadow Mode disguise features.
// ─────────────────────────────────────────────────────────────────────────────

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: StiraAuthService().authStateStream,
      builder: (context, snapshot) {
        // Waiting for Firebase to resolve the persisted auth state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }

        final storage = StorageService();

        // ── Guest Mode ──────────────────────────────────────────────────────
        // User chose "Continue as Guest" — treat as authenticated locally.
        if (storage.isGuestMode && snapshot.data == null) {
          final onboardingDone = storage.onboardingCompleted;
          if (!onboardingDone) {
            return ShadowWrapper(child: const NameInputScreen());
          }
          return ShadowWrapper(child: const MainNavigation());
        }

        // ── Unauthenticated ─────────────────────────────────────────────────
        if (!snapshot.hasData || snapshot.data == null) {
          return ShadowWrapper(child: const WelcomeScreen());
        }

        // ── Authenticated ───────────────────────────────────────────────────
        // Check onboarding status from local Hive (fast, no network call).
        final onboardingDone = storage.onboardingCompleted;

        if (!onboardingDone) {
          // New user: ask for their name first, then go straight to the app.
          return ShadowWrapper(child: const NameInputScreen());
        }

        // Returning user: go straight to the main app.
        return ShadowWrapper(child: const MainNavigation());
      },
    );
  }
}

// ─── Splash Loader ────────────────────────────────────────────────────────────

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF07060F), // StiraTokens.stiraBg
      body: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF1ECFB3), // StiraTokens.stiraTeal
          ),
        ),
      ),
    );
  }
}

// ─── Shadow Wrapper ───────────────────────────────────────────────────────────
//
// Intercepts the app launch and shows a disguise screen if Shadow Mode is
// active. The user must perform the unlock gesture to reveal the real app.
// ─────────────────────────────────────────────────────────────────────────────

class ShadowWrapper extends StatefulWidget {
  final Widget child;
  const ShadowWrapper({super.key, required this.child});

  @override
  State<ShadowWrapper> createState() => _ShadowWrapperState();
}

class _ShadowWrapperState extends State<ShadowWrapper> {
  late String _activeDisguise;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _activeDisguise = StorageService().activeDisguise;
  }

  void _onUnlock() {
    setState(() {
      _isUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

}
