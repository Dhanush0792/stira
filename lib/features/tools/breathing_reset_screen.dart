import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_primary_button.dart';

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
      duration: const Duration(seconds: 12), // 3 phases of 4s = 12s
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _breathCtrl.stop();
        // Completed
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
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  StiraTokens.stiraTeal.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
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
                const Spacer(),
                if (_secondsRemaining > 0)
                  AnimatedBuilder(
                    animation: _breathCtrl,
                    builder: (_, __) {
                      final t = _breathCtrl.value;
                      double scale;
                      String phase;
                      Color color;
                      String subtitle;

                      if (t < (1/3)) {
                        phase = 'INHALE';
                        scale = 0.65 + (t / (1/3)) * 0.35;
                        color = StiraTokens.stiraTeal;
                        subtitle = 'Breathe in slowly';
                      } else if (t < (2/3)) {
                        phase = 'HOLD';
                        scale = 1.0;
                        color = StiraTokens.stiraViolet;
                        subtitle = 'Hold your breath';
                      } else {
                        phase = 'EXHALE';
                        scale = 1.0 - ((t - (2/3)) / (1/3)) * 0.35;
                        color = StiraTokens.stiraPink;
                        subtitle = 'Breathe out slowly';
                      }

                      return Center(
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.1),
                              border: Border.all(
                                color: color.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: scale * 0.4),
                                  blurRadius: 50 * scale,
                                  spreadRadius: 10 * scale,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  phase,
                                  style: GoogleFonts.dmMono(
                                    fontSize: 14,
                                    letterSpacing: 2,
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: StiraTokens.stiraMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  Column(
                    children: [
                      const Icon(Icons.check_circle_outline, color: StiraTokens.stiraTeal, size: 80),
                      const SizedBox(height: 24),
                      Text(
                        'Protocol Complete',
                        style: GoogleFonts.syne(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: StiraTokens.stiraWhite,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your nervous system has been reset.',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: StiraTokens.stiraMuted,
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
