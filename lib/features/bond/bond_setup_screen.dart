import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../services/stira_bond_service.dart';
import '../../services/stira_auth_service.dart';
import 'bond_connect_screen.dart';
import '../../core/models/notification_state.dart';
import 'dart:async';
import '../../core/tour/stira_info_icon.dart';

class BondSetupScreen extends ConsumerStatefulWidget {
  const BondSetupScreen({super.key});

  @override
  ConsumerState<BondSetupScreen> createState() => _BondSetupScreenState();
}

class _BondSetupScreenState extends ConsumerState<BondSetupScreen> {
  bool _isGenerating = false;
  String? _generatedCode;
  StreamSubscription? _requestSub;
  Map<String, dynamic>? _pendingRequest;

  @override
  void initState() {
    super.initState();
    _checkExistingCode();
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    super.dispose();
  }

  Future<void> _checkExistingCode() async {
    final user = StiraAuthService().getCurrentUser();
    if (user == null) return;
    
    // Check if user already has a code generated in Firestore
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final code = doc.data()?['bond_code'] as String?;
      if (code != null && code.isNotEmpty) {
        setState(() => _generatedCode = code);
        _startListening(code);
      }
    }
  }

  void _startListening(String code) {
    _requestSub?.cancel();
    _requestSub = StiraBondService().listenForIncomingRequest(code).listen((data) {
      if (data != null && mounted) {
        setState(() => _pendingRequest = data);
      } else if (mounted) {
        setState(() => _pendingRequest = null);
      }
    });
  }

  Future<void> _accept() async {
    if (_generatedCode == null || _pendingRequest == null) return;
    final user = StiraAuthService().getCurrentUser();
    if (user == null) return;

    setState(() => _isGenerating = true);
    try {
      await StiraBondService().acceptBondRequest(_generatedCode!, user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bond Activated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateCode() async {
    final user = StiraAuthService().getCurrentUser();
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: You must be logged in to generate a code.')),
        );
      }
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final code = await StiraBondService().generateBondCode(user.uid);
      setState(() => _generatedCode = code);
      _startListening(code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
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
                      Row(
                        children: [
                          Text(
                            'Bond Mode',
                            style: GoogleFonts.syne(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: StiraTokens.stiraWhite,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const StiraInfoIcon(featureId: 'bond_mode'),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text('🤝', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 24),
                        Text(
                          'Connection over Impulse.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.syne(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: StiraTokens.stiraWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bond Mode connects you with one trusted person. You share your streak, and optionally, your urge intensity in real-time.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: StiraTokens.stiraMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),

                        if (_generatedCode == null) ...[
                          StiraGlassCard(
                            accentColor: StiraTokens.stiraViolet,
                            child: Column(
                              children: [
                                Text(
                                  'Ask your partner to scan your code, or enter theirs below.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: StiraTokens.stiraWhite.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                StiraPrimaryButton(
                                  label: 'Generate My Code',
                                  color: StiraTokens.stiraViolet,
                                  isLoading: _isGenerating,
                                  onTap: _isGenerating ? null : _generateCode,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const BondConnectScreen()),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: StiraTokens.stiraWhite.withOpacity(0.1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    minimumSize: const Size(double.infinity, 50),
                                    foregroundColor: StiraTokens.stiraWhite,
                                  ),
                                  child: const Text('Enter Partner\'s Code'),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          StiraGlassCard(
                            accentColor: StiraTokens.stiraViolet,
                            child: Column(
                              children: [
                                Text(
                                  'Your Bond Code',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: StiraTokens.stiraMuted,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _generatedCode!,
                                  style: GoogleFonts.syne(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w800,
                                    color: StiraTokens.stiraViolet,
                                    letterSpacing: 8,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (_pendingRequest != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: StiraTokens.stiraViolet.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: StiraTokens.stiraViolet.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${_pendingRequest!['guest_name']} wants to bond!',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: StiraTokens.stiraWhite,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        StiraPrimaryButton(
                                          label: 'Accept Bond',
                                          color: StiraTokens.stiraViolet,
                                          onTap: _accept,
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    'Waiting for partner to connect...',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: StiraTokens.stiraMuted,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                Text(
                                  'Once they enter this code and you accept, your bond will be active.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: StiraTokens.stiraMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 40),
                        _buildFeatureRow(
                          '🔐',
                          'Private',
                          'Only your partner sees your data.',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                          '🔥',
                          'Shared Streak',
                          'Watch your stability grow together.',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                          '💡',
                          'Intervention',
                          'Partner gets notified to help when you are vulnerable.',
                        ),
                      ],
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

  Widget _buildFeatureRow(String emoji, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: StiraTokens.stiraWhite.withOpacity(0.05),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: StiraTokens.stiraWhite,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: StiraTokens.stiraMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
