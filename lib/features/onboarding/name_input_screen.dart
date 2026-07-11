import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/stira_tokens.dart';
import '../../services/local_storage.dart';
import '../navigation/main_navigation.dart';

// ─── Name Input Screen ────────────────────────────────────────────────────────
// Shown to new users right after they sign in (Google or Guest).
// Simple, friendly — just asks their first name, then goes to MainNavigation.
// Saves name both to local Hive and Firestore.
// ─────────────────────────────────────────────────────────────────────────────

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Pre-fill with Google display name if available
    final googleName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    if (googleName.isNotEmpty) {
      final firstName = googleName.split(' ').first;
      _controller.text = firstName;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    // Auto-focus keyboard
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);

    final storage = StorageService();
    // Save to local Hive first
    final existingProfile = storage.getProfile() ?? {};
    existingProfile['name'] = name;
    await storage.saveProfile(existingProfile);
    await storage.setOnboardingCompleted();

    // Save to Firebase Firestore for logged-in users
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'profile': {
            'name': name,
            'email': user.email ?? '',
            'photoUrl': user.photoURL ?? '',
          },
          'onboardingCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('NameInput: Firestore save failed: $e');
        // Continue anyway — local save is enough
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigation(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(decoration: StiraTokens.bgVioletCenterGlow),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // Greeting
                    Text(
                      'What should we call you?',
                      style: GoogleFonts.syne(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: StiraTokens.stiraWhite,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'We\'ll use your name to personalise\nyour experience.',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: StiraTokens.stiraMuted,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Name input
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: StiraTokens.stiraWhite.withValues(alpha: 0.06),
                        border: Border.all(
                          color: StiraTokens.stiraViolet.withValues(alpha: 0.4),
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.syne(
                          color: StiraTokens.stiraWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Your first name',
                          hintStyle: GoogleFonts.syne(
                            color: StiraTokens.stiraMuted.withValues(alpha: 0.5),
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: StiraTokens.stiraMuted, size: 18),
                                  onPressed: () =>
                                      setState(() => _controller.clear()),
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _continue(),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_controller.text.trim().isEmpty || _loading)
                            ? null
                            : _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StiraTokens.stiraPink,
                          disabledBackgroundColor:
                              StiraTokens.stiraMuted.withValues(alpha: 0.15),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Let\'s go  →',
                                style: GoogleFonts.syne(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
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
