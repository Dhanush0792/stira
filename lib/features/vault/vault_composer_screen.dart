import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/stira_tokens.dart';
import '../../services/stira_auth_service.dart';
import '../../services/stira_vault_service.dart';
import '../../services/stira_intelligence_engine.dart';

class VaultComposerScreen extends ConsumerStatefulWidget {
  const VaultComposerScreen({super.key});

  @override
  ConsumerState<VaultComposerScreen> createState() => _VaultComposerScreenState();
}

class _VaultComposerScreenState extends ConsumerState<VaultComposerScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedTag = 'Strong';
  bool _isSaving = false;

  final List<String> _tags = [
    'Strong',
    'Calm',
    'Hopeful',
    'Determined',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveLetter() async {
    final user = StiraAuthService().getCurrentUser();
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      await StiraVaultService().saveVaultLetter(
        userId: user.uid,
        content: _controller.text,
        emotionalTag: _selectedTag,
      );
      await StiraIntelligenceEngine.reactToAction(UserAction.checkInSubmitted); // Map to common action or add specific enum
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Letter saved. We will open it when you need it.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving letter: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = _controller.text.trim().isNotEmpty && _selectedTag.isNotEmpty && !_isSaving;

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Warm radial gradient at center
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 200,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StiraTokens.stiraAmber.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
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
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Write to yourself.',
                    style: GoogleFonts.syne(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: StiraTokens.stiraWhite,
                    ),
                  ),
                  Text(
                    'From a place of strength.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: StiraTokens.stiraMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Video Message Button
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Video messages coming soon.')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: StiraTokens.stiraAmber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: StiraTokens.stiraAmber.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam, color: StiraTokens.stiraAmber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Record Video Message',
                            style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: StiraTokens.stiraAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Text field
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StiraTokens.stiraAmber.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: StiraTokens.stiraAmber.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: RepaintBoundary(
                            child: TextField(
                              controller: _controller,
                              maxLines: null,
                              maxLength: 2000,
                              onChanged: (_) => setState(() {}),
                              style: GoogleFonts.dmSans(fontSize: 16, color: StiraTokens.stiraWhite),
                              decoration: InputDecoration(
                                hintText: 'Write what you want to remember when things get hard...',
                                hintStyle: GoogleFonts.dmSans(color: StiraTokens.stiraMuted),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '${_controller.text.length} / 2000',
                            style: GoogleFonts.dmMono(fontSize: 9, color: StiraTokens.stiraMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Emotional tag
                  Text(
                    'How are you feeling?',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: StiraTokens.stiraMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      final bool isSelected = _selectedTag == tag;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTag = tag),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected 
                                ? StiraTokens.stiraAmber.withOpacity(0.15)
                                : StiraTokens.stiraWhite.withOpacity(0.05),
                            border: Border.all(
                              color: isSelected 
                                  ? StiraTokens.stiraAmber.withOpacity(0.5)
                                  : StiraTokens.stiraWhite.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? StiraTokens.stiraAmber : StiraTokens.stiraWhite,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canSave ? _saveLetter : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StiraTokens.stiraAmber,
                        foregroundColor: StiraTokens.stiraBg,
                        disabledBackgroundColor: StiraTokens.stiraAmber.withOpacity(0.2),
                        disabledForegroundColor: StiraTokens.stiraBg.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: StiraTokens.stiraBg),
                            )
                          : Text(
                              'Save Letter',
                              style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
