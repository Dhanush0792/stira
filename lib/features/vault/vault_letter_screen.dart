import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_primary_button.dart';

class VaultLetterScreen extends StatefulWidget {
  final Map<String, dynamic> letterData;
  final bool autoSurface;

  const VaultLetterScreen({
    super.key,
    required this.letterData,
    this.autoSurface = false,
  });

  @override
  State<VaultLetterScreen> createState() => _VaultLetterScreenState();
}

class _VaultLetterScreenState extends State<VaultLetterScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(text);
      setState(() => _isSpeaking = true);
      
      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.letterData['created_at'] as Timestamp?;
    final dateStr = timestamp != null 
        ? DateFormat('MMMM d, yyyy').format(timestamp.toDate())
        : '';
    final tag = widget.letterData['emotional_tag'] ?? 'Feeling Strong';
    final content = widget.letterData['content'] ?? '';

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Amber radial gradient
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StiraTokens.stiraAmber.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!widget.autoSurface)
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
                        )
                      else
                        const SizedBox(width: 28),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: StiraTokens.stiraAmber.withOpacity(0.1),
                          border: Border.all(color: StiraTokens.stiraAmber.withOpacity(0.3)),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: StiraTokens.stiraAmber,
                          ),
                        ),
                      ),
                      
                      Text(
                        dateStr.toUpperCase(),
                        style: GoogleFonts.dmMono(
                          fontSize: 9,
                          color: StiraTokens.stiraMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                if (widget.autoSurface)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: Text(
                      'You wrote this when you felt strong.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: StiraTokens.stiraMuted,
                      ),
                    ),
                  ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Center(
                      child: Text(
                        content,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          height: 1.8,
                          color: StiraTokens.stiraWhite,
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _speak(content),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: StiraTokens.stiraWhite.withOpacity(0.1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: StiraTokens.stiraWhite,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_isSpeaking ? Icons.stop : Icons.volume_up, size: 18),
                              const SizedBox(width: 8),
                              const Text('Read Aloud'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StiraPrimaryButton(
                          label: widget.autoSurface ? "I'm Ready" : "I Remember This",
                          color: StiraTokens.stiraAmber,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
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
