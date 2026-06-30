import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../services/local_storage.dart';

class ShadowModeSettingsScreen extends StatefulWidget {
  const ShadowModeSettingsScreen({super.key});

  @override
  State<ShadowModeSettingsScreen> createState() => _ShadowModeSettingsScreenState();
}

class _ShadowModeSettingsScreenState extends State<ShadowModeSettingsScreen> {
  String _selectedDisguise = 'None';
  bool _isSaving = false;
  final StorageService _storage = StorageService();

  final List<Map<String, dynamic>> _disguises = [
    {'name': 'None', 'icon': Icons.visibility, 'asset': null, 'desc': 'Standard Stira App Icon'},
    {'name': 'Weather', 'icon': Icons.wb_sunny_outlined, 'asset': 'assets/shadow_mode/weather.png', 'desc': 'Disguised as a minimalist weather app'},
    {'name': 'Calculator', 'icon': Icons.calculate_outlined, 'asset': 'assets/shadow_mode/calculator.png', 'desc': 'Disguised as a scientific calculator'},
    {'name': 'Finance', 'icon': Icons.show_chart, 'asset': 'assets/shadow_mode/finance.png', 'desc': 'Disguised as an expense tracker'},
    {'name': 'Notes', 'icon': Icons.edit_note, 'asset': 'assets/shadow_mode/notes.png', 'desc': 'Disguised as a plain text editor'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDisguise = _storage.activeDisguise;
  }

  Future<void> _applyDisguise() async {
    setState(() => _isSaving = true);
    
    await _storage.setActiveDisguise(_selectedDisguise);
    
    // Call native bridge to toggle launcher icon/name
    try {
      const platform = MethodChannel('com.stira.app/shadow_mode');
      await platform.invokeMethod('applyDisguise', {'disguise': _selectedDisguise});
    } catch (e) {
      debugPrint('Native disguise toggle failed: $e');
    }
    
    setState(() => _isSaving = false);
    
    if (!mounted) return;
    
    if (_selectedDisguise == 'None') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shadow Mode disabled. Reverting to Stira icon.'),
          backgroundColor: StiraTokens.stiraTeal,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: StiraTokens.stiraBg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Shadow Mode Active', style: GoogleFonts.syne(color: StiraTokens.stiraWhite, fontWeight: FontWeight.bold)),
          content: Text(
            'Stira is now disguised as $_selectedDisguise.\n\nTo open Stira normally, long-press the center of the $_selectedDisguise screen.',
            style: GoogleFonts.dmSans(color: StiraTokens.stiraMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('I Understand', style: TextStyle(color: StiraTokens.stiraViolet, fontWeight: FontWeight.bold)),
            ),
          ],
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
          Positioned(
            top: 200,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StiraTokens.stiraPink.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
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
                            color: StiraTokens.stiraWhite.withValues(alpha: 0.05),
                            border: Border.all(color: StiraTokens.stiraWhite.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(Icons.arrow_back, size: 16, color: StiraTokens.stiraWhite),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Shadow Mode',
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
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Disguise your recovery journey. When active, the application interface will be swapped for a mundane utility upon launch.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: StiraTokens.stiraMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        Text(
                          'CHOOSE DISGUISE',
                          style: GoogleFonts.dmMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: StiraTokens.stiraMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        ..._disguises.map((disguise) {
                          final isSelected = _selectedDisguise == disguise['name'];
                          final asset = disguise['asset'] as String?;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedDisguise = disguise['name'] as String),
                              child: StiraGlassCard(
                                accentColor: isSelected ? StiraTokens.stiraViolet : StiraTokens.stiraGlassBorder,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isSelected ? StiraTokens.stiraViolet.withValues(alpha: 0.1) : StiraTokens.stiraGlass,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: asset != null 
                                          ? Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(disguise['icon'] as IconData, color: isSelected ? StiraTokens.stiraViolet : StiraTokens.stiraMuted))
                                          : Icon(disguise['icon'] as IconData, color: isSelected ? StiraTokens.stiraViolet : StiraTokens.stiraMuted),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            disguise['name'] as String,
                                            style: GoogleFonts.syne(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: StiraTokens.stiraWhite,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            disguise['desc'] as String,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: StiraTokens.stiraMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle, color: StiraTokens.stiraViolet, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 32),
                        StiraPrimaryButton(
                          label: 'Apply Changes',
                          color: StiraTokens.stiraViolet,
                          isLoading: _isSaving,
                          onTap: _applyDisguise,
                        ),
                        const SizedBox(height: 24),

                        StiraGlassCard(
                          accentColor: StiraTokens.stiraTeal,
                          fullWidth: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.security, color: StiraTokens.stiraTeal, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SECURITY NOTICE',
                                    style: GoogleFonts.dmMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: StiraTokens.stiraTeal,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Shadow Mode uses local-only transformations. Notifications will also be disguised with generic content when active.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: StiraTokens.stiraMuted,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
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
}
