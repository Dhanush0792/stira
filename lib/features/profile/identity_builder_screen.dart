import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../services/local_storage.dart';
import '../reflection/future_you_screen.dart';
import '../../core/tour/stira_info_icon.dart';

class IdentityBuilderScreen extends StatefulWidget {
  const IdentityBuilderScreen({super.key});

  @override
  State<IdentityBuilderScreen> createState() => _IdentityBuilderScreenState();
}

class _IdentityBuilderScreenState extends State<IdentityBuilderScreen> {
  final List<String> _coreValues = [
    'Authenticity', 'Resilience', 'Courage', 'Patience', 'Clarity', 'Growth',
    'Connection', 'Freedom', 'Discipline'
  ];
  final Set<String> _selectedValues = {'Resilience', 'Clarity'};

  final List<String> _affirmations = [
    "I am rebuilding my baseline. Every urge navigated is proof of my changing brain.",
    "My worth is not defined by my past, but by the stability I build today.",
    "I possess the strength to navigate discomfort without compromising my values.",
    "Every small choice for stability is a giant leap for my future self.",
    "I am the architect of my own peace and the guardian of my own progress.",
    "My focus is on growth, and my resilience grows with every challenge I meet.",
    "I am becoming the version of myself that I have always admired.",
    "Stability is a practice, and today I practice with intention and grace.",
    "I choose clarity over impulse and long-term freedom over short-term relief.",
    "My brain is healing, and my capacity for joy is expanding every day."
  ];

  late int _currentAffirmationIndex;
  late int _refreshCount;
  bool _isCoolingDown = false;

  @override
  void initState() {
    super.initState();
    _loadAffirmationState();
  }

  void _loadAffirmationState() {
    final storage = StorageService();
    _currentAffirmationIndex = storage.affirmationIndex;
    _refreshCount = storage.affirmationRefreshCount;
    
    final lastRefresh = storage.lastAffirmationRefreshDate;
    if (lastRefresh != null) {
      final diff = DateTime.now().difference(lastRefresh);
      if (diff.inDays < 1) { // 1 day cooling period for simplicity, can be adjusted
        if (_refreshCount >= 5) {
          _isCoolingDown = true;
        }
      } else {
        // Reset refresh count after 1 day
        _refreshCount = 0;
        storage.setAffirmationRefreshCount(0);
        _isCoolingDown = false;
      }
    }
  }

  Future<void> _generateNewAffirmation() async {
    if (_isCoolingDown) return;

    final storage = StorageService();
    setState(() {
      _refreshCount++;
      _currentAffirmationIndex = (_currentAffirmationIndex + 1) % _affirmations.length;
      
      if (_refreshCount >= 5) {
        _isCoolingDown = true;
        storage.setLastAffirmationRefreshDate(DateTime.now());
      }
    });

    await storage.setAffirmationIndex(_currentAffirmationIndex);
    await storage.setAffirmationRefreshCount(_refreshCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: 150,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StiraTokens.stiraViolet.withValues(alpha: 0.15),
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
                      Row(
                        children: [
                          Text(
                            'Identity Builder',
                            style: GoogleFonts.syne(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: StiraTokens.stiraWhite,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const StiraInfoIcon(featureId: 'identity_builder'),
                        ],
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
                        // Daily Affirmation
                        Text(
                          'TODAY\'S AFFIRMATION',
                          style: GoogleFonts.dmMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: StiraTokens.stiraViolet,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        StiraGlassCard(
                          accentColor: StiraTokens.stiraViolet,
                          fullWidth: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '"${_affirmations[_currentAffirmationIndex]}"',
                                style: GoogleFonts.syne(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: StiraTokens.stiraWhite,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _isCoolingDown ? null : _generateNewAffirmation,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.refresh, 
                                      color: _isCoolingDown ? StiraTokens.stiraMuted.withValues(alpha: 0.3) : StiraTokens.stiraMuted, 
                                      size: 16
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isCoolingDown ? 'Cooling period active' : 'Tap to generate new',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12, 
                                        color: _isCoolingDown ? StiraTokens.stiraMuted.withValues(alpha: 0.3) : StiraTokens.stiraMuted
                                      ),
                                    ),
                                    if (!_isCoolingDown) ...[
                                      const Spacer(),
                                      Text(
                                        '$_refreshCount/5',
                                        style: GoogleFonts.dmMono(fontSize: 10, color: StiraTokens.stiraMuted),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Values Selection
                        Text(
                          'CORE VALUES',
                          style: GoogleFonts.dmMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: StiraTokens.stiraTeal,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select your foundational pillars. What are you moving toward?',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: StiraTokens.stiraMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _coreValues.map((value) {
                            final isSelected = _selectedValues.contains(value);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedValues.remove(value);
                                  } else {
                                    if (_selectedValues.length < 3) {
                                      _selectedValues.add(value);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Select up to 3 core values.')),
                                      );
                                    }
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? StiraTokens.stiraTeal.withValues(alpha: 0.2) : StiraTokens.stiraGlass,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? StiraTokens.stiraTeal : StiraTokens.stiraGlassBorder,
                                  ),
                                ),
                                child: Text(
                                  value,
                                  style: GoogleFonts.syne(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? StiraTokens.stiraTeal : StiraTokens.stiraMuted,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),

                        // Future You Statement
                        StiraGlassCard(
                          accentColor: StiraTokens.stiraPink,
                          fullWidth: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.edit_note, color: StiraTokens.stiraPink),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Statement of Intent',
                                    style: GoogleFonts.syne(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: StiraTokens.stiraWhite,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'A reminder to yourself from a place of strength.',
                                style: GoogleFonts.dmSans(fontSize: 13, color: StiraTokens.stiraMuted),
                              ),
                              const SizedBox(height: 16),
                              StiraPrimaryButton(
                                label: 'Edit Statement',
                                color: StiraTokens.stiraPink,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FutureYouScreen())),
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
