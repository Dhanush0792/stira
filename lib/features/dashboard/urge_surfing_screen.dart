import 'package:flutter/material.dart';
import '../../core/theme/earth_night.dart';
import '../../services/telemetry_service.dart';

/// A dynamic friction screen that forces a 60-second breathing
/// exercise before allowing the user to submit a high urge log.
class UrgeSurfingScreen extends StatefulWidget {
  const UrgeSurfingScreen({super.key});

  @override
  State<UrgeSurfingScreen> createState() => _UrgeSurfingScreenState();
}

class _UrgeSurfingScreenState extends State<UrgeSurfingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _secondsRemaining = 60;
  String _currentPrompt = 'High urge detected. That is okay.\nWe are going to surf it.';

  @override
  void initState() {
    super.initState();
    TelemetryService.trackUrgeSurfingStarted();
    _controller = AnimationController(
      // 8-second total cycle (4 in, 4 out)
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
          _currentPrompt = "We aren't going to fight the urge.\nJust watch it crest.";
        } else if (_secondsRemaining <= 40 && _secondsRemaining > 20) {
          _currentPrompt = "Breathe in with the circle... and out.";
        } else if (_secondsRemaining <= 20 && _secondsRemaining > 0) {
          _currentPrompt = "Urges are like ocean waves. They peak, and then they break.";
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitWarning();
      },
      child: Scaffold(
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
                          onPressed: () {
                            TelemetryService.trackUrgeSurfingCompleted(10);
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EarthNight.accentViolet,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Log the Urge"),
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
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: _showExitWarning,
                    child: const Text(
                      'Cancel Check-In',
                      style: TextStyle(color: EarthNight.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExitWarning() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EarthNight.surface,
        title: const Text('Cancel Check-In?', style: TextStyle(color: EarthNight.textPrimary)),
        content: const Text(
          'If you exit now, this check-in will be discarded.',
          style: TextStyle(color: EarthNight.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // close dialog
            child: const Text('Keep Surfing', style: TextStyle(color: EarthNight.accentViolet)),
          ),
          TextButton(
            onPressed: () {
              TelemetryService.trackUrgeSurfingAborted();
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(context).pop(false); // pop UrgeSurfingScreen with false
            },
            child: const Text('Discard', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
