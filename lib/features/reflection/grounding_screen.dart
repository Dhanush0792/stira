import 'package:flutter/material.dart';
import '../../core/theme/earth_night.dart';
import '../../services/local_storage.dart';
import 'dart:math';

/// A DBT distress tolerance screen that forces a 60-second breathing
/// exercise before allowing the user to proceed.
class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _secondsRemaining = 60;
  String _currentPrompt = 'Your nervous system is elevated right now. That is okay.';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       // 4-7-8 roughly translated to continuous smooth in/out for simple visuals:
       // We'll use an 8-second total cycle (4 in, 4 out)
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _startTimer();
  }

  void _startTimer() async {
    while (_secondsRemaining > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 50 && _secondsRemaining > 40) {
          _currentPrompt = "We aren't going to fight the urge. We are just going to sit with it.";
        } else if (_secondsRemaining <= 40 && _secondsRemaining > 20) {
          _currentPrompt = "Breathe in with the circle... and out.";
        } else if (_secondsRemaining <= 20 && _secondsRemaining > 0) {
          _currentPrompt = "Urges are like ocean waves. They peak, and then they break. Ride this one out.";
        } else if (_secondsRemaining <= 0) {
          _depositFragment();
        }
      });
    }
  }

  void _depositFragment() {
    final fragments = [
      "The baseline is steady. You are exactly where you need to be.",
      "Urges are objects. You are the sky.",
      "Resistance is exhausting. Acceptance is quiet.",
      "A pathway was triggered, but you chose a different route today.",
      "Every time you pause, you literally rewrite a neural pathway."
    ];
    final selected = fragments[Random().nextInt(fragments.length)];
    StorageService().addVaultFragment(selected);
    
    // Slight delay to allow the UI to finish the timer transition
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A Memory Fragment has been secured in The Vault.'),
          backgroundColor: EarthNight.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EarthNight.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  _currentPrompt,
                  key: ValueKey<String>(_currentPrompt),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: EarthNight.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Scale from 1.0 to 1.8
                  final scale = 1.0 + (_controller.value * 0.8);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: EarthNight.accentViolet.withValues(alpha: 0.15),
                        border: Border.all(
                          color: EarthNight.accentViolet.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
              if (_secondsRemaining <= 0) ...[
                const Text(
                  "Has the wave started to pass?",
                  style: TextStyle(
                    color: EarthNight.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _secondsRemaining = 60;
                            _currentPrompt = "Breathe in with the circle... and out.";
                            _startTimer();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: EarthNight.textSecondary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: const Text(
                          "I need another minute",
                          style: TextStyle(color: EarthNight.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EarthNight.accentViolet,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Yes, continue"),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                 Text(
                  "0:${_secondsRemaining.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    color: EarthNight.textSecondary,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
