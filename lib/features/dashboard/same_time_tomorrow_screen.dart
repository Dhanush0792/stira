import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../services/stira_intelligence_engine.dart';

class SameTimeTomorrowScreen extends StatefulWidget {
  const SameTimeTomorrowScreen({super.key});

  @override
  State<SameTimeTomorrowScreen> createState() => _SameTimeTomorrowScreenState();
}

class _SameTimeTomorrowScreenState extends State<SameTimeTomorrowScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;

  Future<void> _saveCommitment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _saving = true);
    
    final box = Hive.box('commitments');
    await box.add({
      'commitment': text,
      'saved_at': DateTime.now().toIso8601String(),
      'outcome': null, // null = pending, true = kept, false = broken
    });

    await StiraIntelligenceEngine.reactToAction(UserAction.commitmentSaved);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commitment saved. We\'ll check in with you tomorrow.'),
          backgroundColor: StiraTokens.stiraViolet,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: StiraTokens.stiraWhite),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Same Time\nTomorrow.',
                    style: GoogleFonts.syne(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: StiraTokens.stiraWhite,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The best time to plan for a craving is 24 hours before it hits. What will you do instead tomorrow?',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: StiraTokens.stiraMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  StiraGlassCard(
                    accentColor: StiraTokens.stiraViolet,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MY COMMITMENT',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            color: StiraTokens.stiraViolet,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _controller,
                          maxLines: 4,
                          autofocus: true,
                          style: GoogleFonts.dmSans(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'e.g. I will take a 10min walk and leave my phone in the drawer.',
                            hintStyle: GoogleFonts.dmSans(color: StiraTokens.stiraMuted, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  StiraPrimaryButton(
                    label: 'Lock Commitment',
                    color: StiraTokens.stiraViolet,
                    onTap: _saving ? null : _saveCommitment,
                  ),
                ],
              ),
            ),
          ),
          if (_saving)
            const Center(child: CircularProgressIndicator(color: StiraTokens.stiraViolet)),
        ],
      ),
    );
  }
}
