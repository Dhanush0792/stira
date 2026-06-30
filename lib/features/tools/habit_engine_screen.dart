import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';

class HabitEngineScreen extends StatefulWidget {
  const HabitEngineScreen({super.key});

  @override
  State<HabitEngineScreen> createState() => _HabitEngineScreenState();
}

class _HabitEngineScreenState extends State<HabitEngineScreen> {
  final List<Map<String, dynamic>> _habits = [
    {'title': 'Cold Water Splash', 'emoji': '🚿', 'duration': '1 min', 'completed': false, 'desc': 'Shock your system and reduce physical urges.'},
    {'title': 'Walk Redirect', 'emoji': '🚶', 'duration': '10 min', 'completed': false, 'desc': 'Change your physical environment entirely.'},
    {'title': '10 Pushups', 'emoji': '💪', 'duration': '3 min', 'completed': false, 'desc': 'Convert anxious energy into physical exertion.'},
    {'title': 'Call an Ally', 'emoji': '📞', 'duration': '15 min', 'completed': false, 'desc': 'Break the isolation pattern immediately.'},
  ];

  int _urgeReduction = 0;

  void _toggleHabit(int index, bool? val) {
    if (val == true && !_habits[index]['completed']) {
      setState(() {
        _habits[index]['completed'] = true;
        _urgeReduction += 2; // Mock reduction
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Urge reduced. Good job breaking the pattern.'),
          backgroundColor: StiraTokens.stiraTeal,
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
          // Background Glow
          if (_urgeReduction > 0)
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
                      StiraTokens.stiraTeal.withValues(alpha: 0.15),
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
                      Text(
                        'Replacement Habits',
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
                  child: ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemCount: _habits.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_urgeReduction > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: StiraTokens.stiraTeal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: StiraTokens.stiraTeal.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.trending_down, color: StiraTokens.stiraTeal),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Urge intensity reduced by $_urgeReduction points today.',
                                          style: GoogleFonts.dmSans(color: StiraTokens.stiraTeal, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                'Engage in a healthy alternative to override the craving.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: StiraTokens.stiraMuted,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      final habit = _habits[index - 1];
                      final isCompleted = habit['completed'] as bool;
                      
                      return StiraGlassCard(
                        accentColor: isCompleted ? StiraTokens.stiraTeal : StiraTokens.stiraGlassBorder,
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isCompleted ? StiraTokens.stiraTeal.withValues(alpha: 0.1) : StiraTokens.stiraWhite.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(habit['emoji'] as String, style: const TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit['title'] as String,
                                    style: GoogleFonts.syne(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isCompleted ? StiraTokens.stiraWhite : StiraTokens.stiraWhite.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${habit['duration']} • ${habit['desc']}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: StiraTokens.stiraMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Checkbox(
                              value: isCompleted,
                              activeColor: StiraTokens.stiraTeal,
                              side: BorderSide(color: StiraTokens.stiraMuted),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => _toggleHabit(index - 1, val),
                            ),
                          ],
                        ),
                      );
                    },
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
