import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/stira_tokens.dart';
import '../../../widgets/stira_glass_card.dart';
import '../../../widgets/stira_primary_button.dart';
import '../../../services/stira_haptic_service.dart';

class PatternRecallScreen extends StatefulWidget {
  const PatternRecallScreen({super.key});

  @override
  State<PatternRecallScreen> createState() => _PatternRecallScreenState();
}

class _PatternRecallScreenState extends State<PatternRecallScreen> {
  final List<int> _sequence = [];
  final List<int> _userSequence = [];
  bool _isPlayingSequence = false;
  int _activeLevel = 1;
  int _highlightedIndex = -1;
  bool _isGameOver = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startNextLevel();
  }

  Future<void> _startNextLevel() async {
    _sequence.clear();
    _userSequence.clear();
    for (int i = 0; i < _activeLevel + 2; i++) {
      _sequence.add(_random.nextInt(9));
    }

    setState(() {
      _isPlayingSequence = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() => _highlightedIndex = _sequence[i]);
      StiraHapticService().triggerSOSHeartbeat(); // Subtle heartbeat for flash
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _highlightedIndex = -1);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (mounted) {
      setState(() {
        _isPlayingSequence = false;
      });
    }
  }

  void _onTileTap(int index) {
    if (_isPlayingSequence || _isGameOver) return;

    setState(() {
      _userSequence.add(index);
    });

    if (_userSequence.last != _sequence[_userSequence.length - 1]) {
      StiraHapticService().triggerError();
      setState(() => _isGameOver = true);
    } else {
      StiraHapticService().triggerSuccess();
      if (_userSequence.length == _sequence.length) {
        if (_activeLevel >= 5) {
          setState(() => _isGameOver = true);
        } else {
          setState(() => _activeLevel++);
          _startNextLevel();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          Container(decoration: StiraTokens.bgVioletCenterGlow),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isGameOver ? _buildGameOver() : _buildGameContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: StiraTokens.stiraWhite),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text(
              'Level $_activeLevel / 5',
              style: GoogleFonts.dmMono(color: StiraTokens.stiraMuted, fontSize: 13),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const Spacer(),
        Text(
          _isPlayingSequence ? 'WATCH THE PATTERN' : 'REPEAT THE PATTERN',
          style: GoogleFonts.dmMono(
            color: _isPlayingSequence ? StiraTokens.stiraAmber : StiraTokens.stiraTeal,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final isHighlighted = _highlightedIndex == index;
              return InkWell(
                onTap: () => _onTileTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isHighlighted
                        ? StiraTokens.stiraViolet
                        : StiraTokens.stiraViolet.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isHighlighted
                          ? StiraTokens.stiraWhite
                          : StiraTokens.stiraViolet.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: isHighlighted
                        ? [
                            BoxShadow(
                              color: StiraTokens.stiraViolet.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            )
                          ]
                        : [],
                  ),
                ),
              );
            },
          ),
        ),
        const Spacer(),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildGameOver() {
    final success = _activeLevel >= 5 && _userSequence.length == _sequence.length;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          success ? Icons.psychology_outlined : Icons.replay_outlined,
          color: StiraTokens.stiraViolet,
          size: 80,
        ),
        const SizedBox(height: 24),
        Text(
          success ? 'Memory Mastered' : 'Try Again',
          style: GoogleFonts.syne(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: StiraTokens.stiraWhite,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          success
              ? 'Level 5 Complete.\nWorking memory is fully engaged.'
              : 'Stopped at Level $_activeLevel.\nFocus is a practice, keep going.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(color: StiraTokens.stiraMuted, fontSize: 15),
        ),
        const SizedBox(height: 48),
        StiraPrimaryButton(
          label: 'Back to Hub',
          color: StiraTokens.stiraViolet,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
