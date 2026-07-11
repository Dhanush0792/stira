import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/stira_tokens.dart';
import '../../../widgets/stira_glass_card.dart';
import '../../../widgets/stira_primary_button.dart';
import '../../../services/stira_haptic_service.dart';

class ColorClashScreen extends StatefulWidget {
  const ColorClashScreen({super.key});

  @override
  State<ColorClashScreen> createState() => _ColorClashScreenState();
}

class _ColorClashScreenState extends State<ColorClashScreen> {
  final List<Map<String, dynamic>> _colorData = [
    {'name': 'RED', 'color': StiraTokens.stiraPink},
    {'name': 'BLUE', 'color': StiraTokens.stiraViolet},
    {'name': 'GREEN', 'color': StiraTokens.stiraTeal},
    {'name': 'AMBER', 'color': StiraTokens.stiraAmber},
  ];

  late String _displayText;
  late Color _displayColor;
  late List<Color> _options;
  int _score = 0;
  int _round = 0;
  final int _totalRounds = 10;
  bool _isGameOver = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    if (_round >= _totalRounds) {
      setState(() => _isGameOver = true);
      return;
    }

    final textIdx = _random.nextInt(_colorData.length);
    int colorIdx;
    do {
      colorIdx = _random.nextInt(_colorData.length);
    } while (colorIdx == textIdx && _random.nextDouble() > 0.2); // 80% chance of clash

    _displayText = _colorData[textIdx]['name'];
    _displayColor = _colorData[colorIdx]['color'];

    _options = _colorData.map((e) => e['color'] as Color).toList();
    _options.shuffle();

    setState(() {
      _round++;
    });
  }

  void _onOptionTap(Color selectedColor) {
    if (selectedColor == _displayColor) {
      StiraHapticService().triggerSuccess();
      setState(() => _score++);
    } else {
      StiraHapticService().triggerError();
    }
    _nextRound();
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
              'Round $_round / $_totalRounds',
              style: GoogleFonts.dmMono(color: StiraTokens.stiraMuted, fontSize: 13),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const Spacer(),
        Text(
          'TAP THE COLOR',
          style: GoogleFonts.dmMono(
            color: StiraTokens.stiraMuted,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(Tap the ink color, not what the word says!)',
          style: GoogleFonts.dmSans(
            color: StiraTokens.stiraMuted.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 24),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _displayText,
            style: GoogleFonts.syne(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              color: _displayColor,
            ),
          ),
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
            final color = _options[index];
            return InkWell(
              onTap: () => _onOptionTap(color),
              child: StiraGlassCard(
                accentColor: color,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
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
        const Icon(Icons.palette_outlined, color: StiraTokens.stiraPink, size: 80),
        const SizedBox(height: 24),
        Text(
          'Clash Complete',
          style: GoogleFonts.syne(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: StiraTokens.stiraWhite,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Score: $_score / $_totalRounds\nInhibitory control reinforced.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(color: StiraTokens.stiraMuted, fontSize: 15),
        ),
        const SizedBox(height: 48),
        StiraPrimaryButton(
          label: 'Back to Hub',
          color: StiraTokens.stiraPink,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
