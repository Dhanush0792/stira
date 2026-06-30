import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../services/local_storage.dart';
import '../../services/auth_service.dart';
import '../../services/stira_relapse_service.dart';
import '../../services/stira_intelligence_engine.dart';

class RelapseScreen extends ConsumerStatefulWidget {
  const RelapseScreen({super.key});

  @override
  ConsumerState<RelapseScreen> createState() => _RelapseScreenState();
}

class _RelapseScreenState extends ConsumerState<RelapseScreen> {
  String? _trigger;
  String? _emotion;
  bool _saving = false;

  final List<String> _triggers = ['Boredom', 'Stress', 'Social Media', 'Fatigue', 'Loneliness', 'Anger'];
  final List<String> _emotions = ['Anxious', 'Numb', 'Restless', 'Frustrated', 'Sad', 'Empty'];

  bool get _isValid => _trigger != null && _emotion != null;

  Future<void> _handleRelapse({required bool useInsurance}) async {
    if (!_isValid) return;
    setState(() => _saving = true);
    
    try {
      final authUser = ref.read(authServiceProvider).currentUser;
      if (authUser != null) {
        await StiraRelapseService().logRelapse(
          userId: authUser.uid,
          trigger: _trigger!,
          useInsurance: useInsurance,
          note: _emotion ?? '',
        );

        await StiraIntelligenceEngine.reactToAction(UserAction.relapseLogged);

        await StorageService().setLastRelapseDate(DateTime.now());
        
        if (mounted) {
          Navigator.pop(context);
          _showSuccessSnackbar(useInsurance);
        }
      }
    } catch (e) {
      debugPrint('Relapse logging failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: StiraTokens.stiraPink),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSuccessSnackbar(bool insured) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(insured 
            ? 'Streak Shield Activated. Streak preserved.'
            : 'Pattern updated. Starting fresh.'),
        backgroundColor: insured ? StiraTokens.stiraViolet : StiraTokens.stiraTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider).value;
    final insuranceCount = userData?['streak_insurance_available'] as int? ?? 0;
    final hasInsurance = insuranceCount > 0;

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          Container(decoration: StiraTokens.bgPinkTopCenterGlow),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StiraTokens.stiraWhite.withOpacity(0.05),
                            border: Border.all(color: StiraTokens.stiraWhite.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.arrow_back, size: 16, color: StiraTokens.stiraWhite),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Relapse Log',
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: StiraTokens.stiraWhite,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Let’s understand\nwhat happened.',
                          style: GoogleFonts.syne(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: StiraTokens.stiraWhite,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Patterns are markers of progress, not failures. Be honest to help the engine adjust.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: StiraTokens.stiraMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildSectionHeader('TRIGGER'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _triggers.map((t) => _ChoiceChip(
                            label: t,
                            selected: _trigger == t,
                            onTap: () => setState(() => _trigger = t),
                            color: StiraTokens.stiraPink,
                          )).toList(),
                        ),
                        const SizedBox(height: 32),

                        _buildSectionHeader('EMOTION BEFORE'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _emotions.map((e) => _ChoiceChip(
                            label: e,
                            selected: _emotion == e,
                            onTap: () => setState(() => _emotion = e),
                            color: StiraTokens.stiraViolet,
                          )).toList(),
                        ),
                        const SizedBox(height: 48),

                        if (hasInsurance) ...[
                          StiraGlassCard(
                            accentColor: StiraTokens.stiraViolet,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text('🛡️', style: TextStyle(fontSize: 24)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'STREAK SHIELD AVAILABLE',
                                            style: GoogleFonts.dmMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: StiraTokens.stiraViolet,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          Text(
                                            'You have $insuranceCount shield(s) remaining.',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: StiraTokens.stiraWhite.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                StiraPrimaryButton(
                                  label: 'Use Streak Shield',
                                  color: StiraTokens.stiraViolet,
                                  onTap: _saving || !_isValid ? null : () => _handleRelapse(useInsurance: true),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _saving || !_isValid ? null : () => _handleRelapse(useInsurance: false),
                                  child: Text(
                                    'Don’t use, reset streak',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: StiraTokens.stiraMuted,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          StiraPrimaryButton(
                            label: 'Log Relapse & Start Fresh',
                            color: StiraTokens.stiraPink,
                            onTap: _saving || !_isValid ? null : () => _handleRelapse(useInsurance: false),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_saving)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(color: StiraTokens.stiraPink)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.dmMono(
        fontSize: 10,
        color: StiraTokens.stiraMuted,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? color.withOpacity(0.15) : StiraTokens.stiraWhite.withOpacity(0.04),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : StiraTokens.stiraWhite.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: selected ? color : StiraTokens.stiraMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
