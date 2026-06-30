import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_primary_button.dart';
import '../../widgets/stira_background_orbs.dart';
import '../../widgets/stira_glass_card.dart';
import 'insight_screen.dart';

class OnboardingAssessment extends StatefulWidget {
  const OnboardingAssessment({super.key});

  @override
  State<OnboardingAssessment> createState() => _OnboardingAssessmentState();
}

class _OnboardingAssessmentState extends State<OnboardingAssessment> with TickerProviderStateMixin {
  int _step = 0;
  final Map<String, dynamic> _data = {};
  final _nameController = TextEditingController();
  String? _error;

  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'What is your primary stability focus?',
      'sub': 'Stira is a regulatory environment for your nervous system. Specify the loop we are interrupting.',
      'options': [
        'Regulating impulsive behavior loops',
        'Managing emotional dysregulation',
        'Recovery from behavioral relapse',
        'Burnout & nervous system grounding'
      ],
      'key': 'intention',
    },
    {
      'title': 'We\'re glad you\'re here. What should we call you?',
      'sub': 'Your name stays entirely on your device.',
      'input': true,
      'key': 'name',
    },
    {
      'title': 'Identify the primary catalyst for your volatility.',
      'sub': 'Knowing the driver allows the intelligence layer to forecast risk accurately.',
      'options': [
        'Acute Stress & Anxiety spikes',
        'Isolation & late-night vulnerability',
        'Digital fatigue & cognitive overload',
        'Environmental & situational triggers'
      ],
      'key': 'trigger',
    },
    {
      'title': 'When does your vulnerability window typically open?',
      'sub': 'We use this to deploy intervention protocols before the autopilot takes over.',
      'options': [
        'The \'Dead Hours\' (Late Night)',
        'The \'Transition Gap\' (Post-Work)',
        'The \'Morning Fog\' (Early Hours)',
        'The \'Stress Peak\' (Mid-Day)'
      ],
      'key': 'window',
    },
    {
      'title': 'Choose your containment intensity.',
      'sub': 'Determines how aggressively Stira intervenes during high-risk windows.',
      'options': [
        'Attentive Regulation (Active Nudges)',
        'Protective Containment (Strict Interventions)',
        'Neutral Support (Minimal Interference)',
        'Ghost Mode Priority (Maximum Privacy)'
      ],
      'key': 'accountability',
    },
    {
      'title': 'Define your state of baseline stability.',
      'sub': 'This is the nervous system \'North Star\' we are guiding you toward.',
      'options': [
        'Calm, focused presence',
        'Absolute freedom from the impulse',
        'Emotional resilience and regulation',
        'Consistent intentional action'
      ],
      'key': 'goal',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _isValid() {
    final key = _questions[_step]['key'] as String;
    if (key == 'name') return _nameController.text.trim().isNotEmpty;
    return _data.containsKey(key) && _data[key] != null;
  }

  void _tryNext() {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    final key = _questions[_step]['key'] as String;
    if (key == 'name') _data['name'] = _nameController.text.trim();
    setState(() => _error = null);
    if (_step < _questions.length - 1) {
      setState(() => _step++);
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => InsightScreen(data: _data),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  void _goBack() {
    HapticFeedback.selectionClick();
    setState(() => _error = null);
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  void _select(String key, String value) {
    HapticFeedback.selectionClick();
    setState(() {
      _data[key] = value;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_step];
    final isInput = q.containsKey('input') && q['input'] == true;
    final selectedValue = _data[q['key'] as String];
    final canContinue = _isValid();

    String titleText = q['title'] as String;
    if (q['key'] == 'trigger') {
      final name = _data['name'] ?? 'Friend';
      titleText = '$name, $titleText';
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Premium Animated Background
          const StiraBackgroundOrbs(),

          SafeArea(
            child: Column(
              children: [
                // Top Progress Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _goBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StiraTokens.stiraGlass,
                            border: Border.all(color: StiraTokens.stiraGlassBorder),
                          ),
                          child: const Icon(Icons.arrow_back, size: 16, color: StiraTokens.stiraWhite),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: List.generate(_questions.length, (i) {
                            final active = i == _step;
                            final done = i < _step;
                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: 3,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: done 
                                    ? StiraTokens.stiraPink 
                                    : (active ? StiraTokens.stiraWhite : StiraTokens.stiraGlassBorder),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: active ? [
                                    BoxShadow(color: StiraTokens.stiraWhite.withValues(alpha: 0.3), blurRadius: 4),
                                  ] : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.05, 0.0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_step),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              titleText,
                              style: StiraTokens.displayHero.copyWith(fontSize: 26),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              q['sub'] as String,
                              style: StiraTokens.bodyText.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 40),
                            
                            if (isInput) 
                              _buildInputField()
                            else 
                              _buildOptions(q, selectedValue),

                            const SizedBox(height: 40),
                            
                            StiraPrimaryButton(
                              label: _step == _questions.length - 1 ? 'Finish →' : 'Continue →',
                              color: canContinue ? StiraTokens.stiraPink : StiraTokens.stiraMuted,
                              onTap: canContinue ? _tryNext : null,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return StiraGlassCard(
      accentColor: StiraTokens.stiraWhite,
      padding: EdgeInsets.zero,
      child: TextField(
        controller: _nameController,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.dmSans(color: StiraTokens.stiraWhite, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Your name',
          hintStyle: GoogleFonts.dmSans(color: StiraTokens.stiraMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildOptions(Map<String, dynamic> q, dynamic selectedValue) {
    return Column(
      children: (q['options'] as List<String>).map((opt) {
        final selected = selectedValue == opt;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _select(q['key'] as String, opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(StiraTokens.radiusCard),
                color: selected 
                  ? StiraTokens.stiraPink.withValues(alpha: 0.12)
                  : StiraTokens.stiraGlass,
                border: Border.all(
                  color: selected 
                    ? StiraTokens.stiraPink.withValues(alpha: 0.6)
                    : StiraTokens.stiraGlassBorder,
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: selected ? [
                  BoxShadow(
                    color: StiraTokens.stiraPink.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: StiraGlassCard(
                accentColor: selected ? StiraTokens.stiraPink : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                fullWidth: true,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        opt,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? StiraTokens.stiraWhite : StiraTokens.stiraMuted,
                        ),
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle_rounded, color: StiraTokens.stiraPink, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

