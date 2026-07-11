import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_primary_button.dart';
import '../../widgets/stira_glass_card.dart';

class BreathingResetScreen extends StatefulWidget {
  const BreathingResetScreen({super.key});

  @override
  State<BreathingResetScreen> createState() => _BreathingResetScreenState();
}

class _BreathingResetScreenState extends State<BreathingResetScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathCtrl;
  Timer? _timer;
  int _secondsRemaining = 120;
  
  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24), // 6 phases of 4s = 24s
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _breathCtrl.stop();
      }
    });
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background glows
          AnimatedBuilder(
            animation: _breathCtrl,
            builder: (context, _) {
              final t = _breathCtrl.value;
              Color activeColor;
              if (t < (1 / 6) || t >= (5 / 6)) {
                activeColor = StiraTokens.stiraTeal; // Ida Nadi / Left
              } else if (t >= (2 / 6) && t < (4 / 6)) {
                activeColor = StiraTokens.stiraPink; // Pingala Nadi / Right
              } else {
                activeColor = StiraTokens.stiraViolet; // Sushumna / Hold
              }
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      activeColor.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Text(
                        'NADI SHODHANA',
                        style: GoogleFonts.syne(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: StiraTokens.stiraWhite,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ALTERNATE NOSTRIL BREATHING',
                        style: GoogleFonts.dmMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: StiraTokens.stiraMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_secondsRemaining > 0)
                  AnimatedBuilder(
                    animation: _breathCtrl,
                    builder: (_, __) {
                      final t = _breathCtrl.value;
                      double scale;
                      String phase;
                      Color color;
                      String instruction;
                      String details;
                      String activeNadi;

                      if (t < (1 / 6)) {
                        phase = 'INHALE LEFT';
                        scale = 0.65 + (t / (1 / 6)) * 0.35;
                        color = StiraTokens.stiraTeal;
                        instruction = 'Close right nostril with thumb, inhale left';
                        details = 'Ida Nadi: Calming, lunar channel';
                        activeNadi = 'LEFT NOSTRIL';
                      } else if (t < (2 / 6)) {
                        phase = 'HOLD';
                        scale = 1.0;
                        color = StiraTokens.stiraViolet;
                        instruction = 'Close both nostrils, hold energy at center';
                        details = 'Antar Kumbhaka: Balances brain hemispheres';
                        activeNadi = 'BOTH CLOSED';
                      } else if (t < (3 / 6)) {
                        phase = 'EXHALE RIGHT';
                        scale = 1.0 - ((t - (2 / 6)) / (1 / 6)) * 0.35;
                        color = StiraTokens.stiraPink;
                        instruction = 'Open right nostril, exhale fully';
                        details = 'Pingala Nadi: Releasing tension';
                        activeNadi = 'RIGHT NOSTRIL';
                      } else if (t < (4 / 6)) {
                        phase = 'INHALE RIGHT';
                        scale = 0.65 + ((t - (3 / 6)) / (1 / 6)) * 0.35;
                        color = StiraTokens.stiraPink;
                        instruction = 'Inhale deeply through right nostril';
                        details = 'Pingala Nadi: Solar channel energy';
                        activeNadi = 'RIGHT NOSTRIL';
                      } else if (t < (5 / 6)) {
                        phase = 'HOLD';
                        scale = 1.0;
                        color = StiraTokens.stiraViolet;
                        instruction = 'Close both nostrils, hold energy at center';
                        details = 'Antar Kumbhaka: Settling mental patterns';
                        activeNadi = 'BOTH CLOSED';
                      } else {
                        phase = 'EXHALE LEFT';
                        scale = 1.0 - ((t - (5 / 6)) / (1 / 6)) * 0.35;
                        color = StiraTokens.stiraTeal;
                        instruction = 'Open left nostril, exhale fully';
                        details = 'Ida Nadi: Returning to baseline calm';
                        activeNadi = 'LEFT NOSTRIL';
                      }

                      return Column(
                        children: [
                          Center(
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(alpha: 0.08),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.45),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: scale * 0.3),
                                      blurRadius: 40 * scale,
                                      spreadRadius: 8 * scale,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      activeNadi,
                                      style: GoogleFonts.dmMono(
                                        fontSize: 9,
                                        letterSpacing: 2,
                                        color: color.withValues(alpha: 0.6),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      phase,
                                      style: GoogleFonts.syne(
                                        fontSize: 16,
                                        letterSpacing: 1.5,
                                        color: color,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Icon(
                                      phase == 'HOLD' ? Icons.lock_outline : Icons.air,
                                      color: color.withValues(alpha: 0.8),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: StiraGlassCard(
                              accentColor: color,
                              fullWidth: true,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Column(
                                  children: [
                                    Text(
                                      instruction,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      details,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: StiraTokens.stiraMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  Column(
                    children: [
                      const Icon(Icons.spa_outlined, color: StiraTokens.stiraTeal, size: 80),
                      const SizedBox(height: 24),
                      Text(
                        'Pranayama Complete',
                        style: GoogleFonts.syne(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: StiraTokens.stiraWhite,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Your solar and lunar energy channels are balanced. Acute stress and urge pathways have been reset.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: StiraTokens.stiraMuted,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                const Spacer(),
                if (_secondsRemaining > 0)
                  Text(
                    '$_secondsRemaining s',
                    style: GoogleFonts.dmMono(
                      fontSize: 24,
                      color: StiraTokens.stiraWhite,
                    ),
                  ),
                const SizedBox(height: 48),
                if (_secondsRemaining <= 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32),
                    child: StiraPrimaryButton(
                      label: 'Return',
                      color: StiraTokens.stiraTeal,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
