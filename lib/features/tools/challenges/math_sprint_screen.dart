import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/stira_tokens.dart';
import '../../../widgets/stira_glass_card.dart';
import '../../../widgets/stira_primary_button.dart';
import '../../../services/stira_haptic_service.dart';

class MathSprintScreen extends StatefulWidget {
  const MathSprintScreen({super.key});

  @override
  State<MathSprintScreen> createState() => _MathSprintScreenState();
}

class _MathSprintScreenState extends State<MathSprintScreen> {
  int _score = 0;
  int _questionCount = 0;
  final int _totalQuestions = 10;
  late String _currentProblem;
  late int _correctAnswer;
  List<int> _options = [];
  bool _isGameOver = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateProblem();
  }

  void _generateProblem() {
    if (_questionCount >= _totalQuestions) {
      setState(() => _isGameOver = true);
      return;
    }

    final a = _random.nextInt(20) + 1;
    final b = _random.nextInt(20) + 1;
    final op = _random.nextBool() ? '+' : '-';

    _currentProblem = '$a $op $b';
    _correctAnswer = op == '+' ? a + b : a - b;

    _options = [_correctAnswer];
    while (_options.length < 4) {
      final off = _random.nextInt(10) - 5;
      final opt = _correctAnswer + off;
      if (!_options.contains(opt)) {
        _options.add(opt);
      }
    }
    _options.shuffle();

    setState(() {
      _questionCount++;
    });
  }

  void _onOptionTap(int val) {
    if (val == _correctAnswer) {
      StiraHapticService().triggerSuccess();
      setState(() => _score++);
    } else {
      StiraHapticService().triggerError();
    }
    _generateProblem();
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
              'Problem $_questionCount / $_totalQuestions',
              style: GoogleFonts.dmMono(color: StiraTokens.stiraMuted, fontSize: 13),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const Spacer(),
        Text(
          _currentProblem,
          style: GoogleFonts.syne(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: StiraTokens.stiraWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Solve to stabilize focus.',
          style: GoogleFonts.dmSans(color: StiraTokens.stiraMuted, fontSize: 14),
        ),
        const Spacer(),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: _options.length,
          itemBuilder: (context, index) {
            final opt = _options[index];
            return InkWell(
              onTap: () => _onOptionTap(opt),
              child: StiraGlassCard(
                accentColor: StiraTokens.stiraTeal,
                child: Center(
                  child: Text(
                    '$opt',
                    style: GoogleFonts.syne(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: StiraTokens.stiraWhite,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildGameOver() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, color: StiraTokens.stiraTeal, size: 80),
        const SizedBox(height: 24),
        Text(
          'Challenge Complete',
          style: GoogleFonts.syne(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: StiraTokens.stiraWhite,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'You solved $_score / $_totalQuestions problems.\nYour prefrontal cortex is back online.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(color: StiraTokens.stiraMuted, fontSize: 15),
        ),
        const SizedBox(height: 48),
        StiraPrimaryButton(
          label: 'Return to Tools',
          color: StiraTokens.stiraTeal,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
