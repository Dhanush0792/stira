import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../widgets/stira_radial_dial.dart';
import '../../core/intelligence_layer.dart';
import '../../services/local_storage.dart';
import '../../services/behavior_service.dart';
import './urge_surfing_screen.dart';
import '../../services/telemetry_service.dart';
import '../../core/stira_routes.dart';
import '../../services/stira_checkin_service.dart';
import '../../services/auth_service.dart';
import '../../services/stira_vault_service.dart';
import '../../services/stira_haptic_service.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/stira_intelligence_engine.dart';
import '../../services/stira_behaviour_analyser.dart';
import '../vault/vault_letter_screen.dart';

class CheckInFlow extends ConsumerStatefulWidget {
  const CheckInFlow({super.key});

  @override
  ConsumerState<CheckInFlow> createState() => _CheckInFlowState();
}

class _CheckInFlowState extends ConsumerState<CheckInFlow>
    with SingleTickerProviderStateMixin {
  int _intensity = 5;
  final Set<String> _selectedTriggers = {};
  String? _selectedLocation;
  String? _selectedEnergy;
  final TextEditingController _noteController = TextEditingController();
  bool _submitted = false;
  late AnimationController _rippleCtrl;
  late Animation<double> _rippleAnim;

  final List<String> _triggers = [
    'Boredom', 'Stress', 'Loneliness', 'Habit', 'Fatigue', 'Social Media'
  ];
  final List<String> _locations = [
    'Home', 'Bedroom', 'Work', 'Outside', 'Other'
  ];
  final List<String> _energyOptions = ['Low', 'Normal', 'High'];

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitted) return;

    // Validation
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your current location.')),
      );
      return;
    }
    if (_selectedTriggers.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 3 triggers.')),
      );
      return;
    }

    _submitted = true;

    // INTERVENTION 0: SOS Heartbeat (Intensity >= 8)
    if (_intensity >= 8) {
      StiraHapticService().triggerSOSHeartbeat();
    }

    // INTERVENTION 1: Urge Surfing (Intensity >= 7)
    if (_intensity >= 7) {
      final bool? completed = await Navigator.of(context).push<bool>(
        StiraSlideUpRoute<bool>(page: const UrgeSurfingScreen()),
      );
      if (!mounted) return;
      if (completed != true) {
        _submitted = false;
        return;
      }
    }

    // INTERVENTION 2: Vault Letter (Intensity >= 8)
    if (_intensity >= 8) {
      final authUser = ref.read(authServiceProvider).currentUser;
      if (authUser != null) {
        final letter = await StiraVaultService().getMostRecentLetter(authUser.uid);
        if (letter != null && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VaultLetterScreen(
                letterData: letter,
                autoSurface: true,
              ),
            ),
          );
        }
      }
    }

    final storage = StorageService();
    final now = DateTime.now();
    if (storage.firstCheckInDate == null) {
      await storage.setFirstCheckInDate(now);
    }

    final mood = _selectedTriggers.isNotEmpty
        ? _selectedTriggers.first
        : 'Not specified';
    final isAlone = _selectedLocation == 'Bedroom' ||
        _selectedLocation == 'Home';

    await storage.addLog({
      'timestamp': now.toIso8601String(),
      'urge': _intensity,
      'mood': mood,
      'alone': isAlone,
      'triggers': _selectedTriggers.toList(),
      'locations': [_selectedLocation],
      'energy': _selectedEnergy,
      'note': _noteController.text.trim(),
    });

    // Notify Intelligence Engine & Analyser
    final userData = Hive.box('user_data');
    final streak = userData.get('current_streak', defaultValue: 0);
    StiraBehaviourAnalyser.syncToHive(
      currentStreak: streak,
      urgeLevel: _intensity,
      triggers: _selectedTriggers.toList(),
      location: _selectedLocation ?? 'other',
    );
    unawaited(StiraIntelligenceEngine.reactToAction(UserAction.checkInSubmitted));

    // Phase 3: Recency Suppression (Validation Pillar)
    await storage.recordLastAction();

    // FIREBASE INTEGRATION:
    try {
      final authUser = ref.read(authServiceProvider).currentUser;
      if (authUser != null) {
        await StiraCheckInService().submitCheckIn(
          userId: authUser.uid,
          urgeLevel: _intensity,
          triggers: _selectedTriggers.toList(),
          location: _selectedLocation ?? 'other',
          mood: mood,
          note: _noteController.text.trim(),
        );
      }
    } catch (e) {
      debugPrint('Firebase check-in sync failed: $e');
    }

    // Bug Fix #3: Immediately sync to cloud so data is safe before next reinstall
    unawaited(() async {
      try {
        final syncUser = FirebaseAuth.instance.currentUser;
        if (syncUser != null) {
          final syncService = CloudSyncService(
            FirebaseFirestore.instance,
            AuthService(FirebaseAuth.instance),
            StorageService(),
          );
          await syncService.syncHistoryToCloud();
        }
      } catch (e) {
        debugPrint('Post-checkin cloud sync failed (non-fatal): $e');
      }
    }());

    await TelemetryService.trackCheckInCompleted(_intensity, isAlone);

    final result = await ref
        .read(intelligenceProvider.notifier)
        .evaluateCheckInAsync(urgeLevel: _intensity, isAlone: isAlone);

    if (result.riskLevel.name == 'elevated' ||
        result.riskLevel.name == 'critical') {
      await storage.incrementElevatedRiskCount();
    }

    ref.read(intelligenceProvider.notifier).recompute();

    // Trigger local intelligence engine: schedule the next smart notification
    unawaited(StiraIntelligenceEngine.runCycle());

    if (!mounted) return;

    await _rippleCtrl.forward();
    if (!mounted) return;

    final message = BehaviorService.microMessage(result.riskLevel.name);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _SuccessDialog(message: message),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        constraints: const BoxConstraints(minHeight: 40),
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? StiraTokens.stiraTeal.withValues(alpha: 0.18)
              : StiraTokens.stiraGlass,
          border: Border.all(
            color: selected
                ? StiraTokens.stiraTeal.withValues(alpha: 0.5)
                : StiraTokens.stiraGlassBorder,
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color:
                selected ? StiraTokens.stiraTeal : StiraTokens.stiraMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // Bug #01 fix: resizeToAvoidBottomInset prevents keyboard overlap
      resizeToAvoidBottomInset: true,
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Teal radial glow background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  StiraTokens.stiraTeal.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Teal ripple celebration on submit
          AnimatedBuilder(
            animation: _rippleAnim,
            builder: (_, __) {
              if (_rippleCtrl.value == 0) return const SizedBox.shrink();
              return Center(
                child: Container(
                  width: _rippleAnim.value * 400,
                  height: _rippleAnim.value * 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: StiraTokens.stiraTeal
                        .withValues(alpha: 1 - _rippleAnim.value),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StiraTokens.stiraGlass,
                            border: Border.all(
                                color: StiraTokens.stiraGlassBorder),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white54, size: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Daily Check-in',
                        style: GoogleFonts.syne(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: StiraTokens.stiraWhite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Rotary Dial ───────────────────────────────────
                  Center(
                    child: StiraRadialDial(
                      value: _intensity,
                      onChanged: (v) => setState(() => _intensity = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'URGE INTENSITY · NOW',
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        color: StiraTokens.stiraTeal,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Trigger chips ───────────────────────────────
                  StiraGlassCard(
                    accentColor: StiraTokens.stiraTeal,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What triggered the urge?',
                          style: GoogleFonts.dmSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: StiraTokens.stiraWhite),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _triggers.map((t) {
                            final selected = _selectedTriggers.contains(t);
                            return _chip(
                              label: t,
                              selected: selected,
                              onTap: () => setState(() {
                                selected
                                    ? _selectedTriggers.remove(t)
                                    : _selectedTriggers.add(t);
                              }),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Location chips ──────────────────────────────
                  StiraGlassCard(
                    accentColor: StiraTokens.stiraTeal,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Where are you right now?',
                          style: GoogleFonts.dmSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: StiraTokens.stiraWhite),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _locations.map((loc) {
                            final selected = _selectedLocation == loc;
                            return _chip(
                              label: loc,
                              selected: selected,
                              onTap: () => setState(() {
                                _selectedLocation = loc;
                              }),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Energy chips ────────────────────────────────
                  StiraGlassCard(
                    accentColor: StiraTokens.stiraTeal,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How's your energy?",
                          style: GoogleFonts.dmSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: StiraTokens.stiraWhite),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _energyOptions.map((e) {
                            final selected = _selectedEnergy == e;
                            return _chip(
                              label: e,
                              selected: selected,
                              onTap: () =>
                                  setState(() => _selectedEnergy = e),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Free-text Note ───────────────────────────────────
                  StiraGlassCard(
                    accentColor: StiraTokens.stiraTeal,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Any thoughts? (Optional)",
                          style: GoogleFonts.dmSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: StiraTokens.stiraWhite),
                        ),
                        const SizedBox(height: 10),
                        RepaintBoundary(
                          child: TextField(
                            controller: _noteController,
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: StiraTokens.stiraWhite),
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Tap to write...',
                              hintStyle: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: StiraTokens.stiraMuted),
                              filled: true,
                              fillColor: StiraTokens.stiraGlass,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bug #01 fix: StiraPrimaryButton always visible,
                  // resizeToAvoidBottomInset handles keyboard overlap
                  StiraPrimaryButton(
                    label: 'Submit Check-in',
                    color: StiraTokens.stiraTeal,
                    textStyle: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    onTap: _submit,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  final String message;
  const _SuccessDialog({required this.message});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Check-in saved.',
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: StiraTokens.stiraTeal,
                  shadows: [
                    Shadow(
                      color: StiraTokens.stiraTeal.withValues(alpha: 0.6),
                      blurRadius: 16,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: StiraTokens.stiraWhite,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
