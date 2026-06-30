import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_primary_button.dart';
import '../../services/stira_bond_service.dart';
import '../../services/stira_auth_service.dart';
import '../../services/local_storage.dart';

class BondConnectScreen extends ConsumerStatefulWidget {
  const BondConnectScreen({super.key});

  @override
  ConsumerState<BondConnectScreen> createState() => _BondConnectScreenState();
}

class _BondConnectScreenState extends ConsumerState<BondConnectScreen> {
  final TextEditingController _controller = TextEditingController();
  String _shareLevel = 'streak_only';
  bool _isConnecting = false;

  final Map<String, String> _levels = {
    'streak_only': 'Share Streak Only',
    'streak_intensity': 'Share Streak + Urge Level',
    'full_insights': 'Share Full Insights (Heatmap, Triggers)',
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final user = StiraAuthService().getCurrentUser();
    if (user == null) return;
    if (_controller.text.length != 6) return;

    final profile = await StorageService().getProfile();
    final String myName = profile?['name'] ?? 'Someone';

    setState(() => _isConnecting = true);
    try {
      final result = await StiraBondService().sendConnectionRequest(
        senderUid: user.uid,
        senderName: myName,
        code: _controller.text,
        shareLevel: _shareLevel,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Request sent to ${result.partnerName}! Waiting for them to accept...'),
              duration: const Duration(seconds: 5),
            ),
          );
          // We stay on this screen or show a pending indicator?
          // For now, let's pop and let the Setup screen handle the "Waiting" state 
          // if we can listen for our own user doc changes.
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(decoration: StiraTokens.bgVioletCenterGlow),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 24),
                  Text(
                    'Connect with Partner',
                    style: GoogleFonts.syne(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: StiraTokens.stiraWhite,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'ENTER 6-DIGIT CODE',
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      color: StiraTokens.stiraMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RepaintBoundary(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: GoogleFonts.syne(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: StiraTokens.stiraViolet,
                        letterSpacing: 12,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: StiraTokens.stiraWhite.withOpacity(0.03),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: StiraTokens.stiraWhite.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: StiraTokens.stiraViolet),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  Text(
                    'WHAT WILL YOU SHARE?',
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      color: StiraTokens.stiraMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._levels.entries.map((e) {
                    final isSelected = _shareLevel == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => _shareLevel = e.key),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected 
                              ? StiraTokens.stiraViolet.withOpacity(0.1)
                              : StiraTokens.stiraWhite.withOpacity(0.03),
                          border: Border.all(
                            color: isSelected 
                                ? StiraTokens.stiraViolet.withOpacity(0.5)
                                : StiraTokens.stiraWhite.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              size: 18,
                              color: isSelected ? StiraTokens.stiraViolet : StiraTokens.stiraMuted,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              e.value,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? StiraTokens.stiraWhite : StiraTokens.stiraMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 48),
                  StiraPrimaryButton(
                    label: 'Complete Connection',
                    color: StiraTokens.stiraViolet,
                    onTap: _isConnecting ? null : _connect,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
