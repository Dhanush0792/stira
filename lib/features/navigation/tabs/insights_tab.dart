import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../theme/stira_tokens.dart';
import '../../../widgets/stira_glass_card.dart';
import '../../../widgets/stira_led_metric.dart';
import '../../../widgets/stira_card_label.dart';
import '../../../core/intelligence_layer.dart';
import '../../../core/stira_stagger.dart';
import '../../tools/dopamine_journal_screen.dart';
import '../../reports/screen_time_screen.dart';
import '../../insights/rewire_map_screen.dart';
import '../../reports/weekly_report_screen.dart';
import '../../../core/common_widgets/placeholder_screen.dart';
import '../../../core/tour/stira_info_icon.dart';

/// Tab 1 — Insights (Stira v2 — migrated to StiraTokens)
class InsightsTab extends ConsumerStatefulWidget {
  const InsightsTab({super.key});

  @override
  ConsumerState<InsightsTab> createState() => _InsightsTabState();
}

class _InsightsTabState extends ConsumerState<InsightsTab>
    with TickerProviderStateMixin, StiraStaggerMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(intelligenceProvider);
    final streak = state.streak;
    final checkinDates = state.checkinDates;
    final topTriggers = state.topTriggers;
    final topLocations = state.topLocations;
    final now = DateTime.now();

    if (state.isGhostMode) {
      return Container(
        color: StiraTokens.stiraBg,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.nights_stay_outlined,
                  size: 40,
                  color: StiraTokens.stiraViolet.withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              Text('Insights Hidden', style: StiraTokens.displayTitle),
              const SizedBox(height: 8),
              Text('Come back tomorrow.', style: StiraTokens.bodyText),
            ],
          ),
        ),
      );
    }

    // Build 7-day data from actual dailyUrgeMap
    final dayData = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final ds = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final intensity = state.dailyUrgeMap[ds] ?? 0;
      return {
        'weekday': day.weekday,
        'isToday': i == 6,
        'intensity': (intensity / 10.0).clamp(0.05, 1.0),
      };
    });

    final topTriggerList = topTriggers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final triggerColors = [
      StiraTokens.stiraPink,
      StiraTokens.stiraAmber,
      StiraTokens.stiraViolet,
      StiraTokens.stiraTeal,
    ];
    final totalTriggers = topTriggerList.fold<int>(0, (s, e) => s + e.value);

    final topLocationList = topLocations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalLocations = topLocationList.fold<int>(0, (s, e) => s + e.value);

    return Container(
      color: StiraTokens.stiraBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(decoration: StiraTokens.bgVioletTopRightGlow),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  staggerItem(0, Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Insights',
                          style: StiraTokens.displayTitle
                              .copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      StiraCardLabel(_weekRange(now)),
                    ]
                  )),
                  const SizedBox(height: 20),

                  // ── Streak hero (amber) ─────────────────────────
                  staggerItem(1, StiraGlassCard(
                    accentColor: StiraTokens.stiraAmber,
                    fullWidth: true,
                    child: Row(
                      children: [
                        StiraLedMetric(
                          value: '$streak',
                          color: StiraTokens.stiraAmber,
                          size: 36,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Day Streak',
                                  style: GoogleFonts.syne(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: StiraTokens.stiraWhite)),
                              Text('Keep the momentum going',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: StiraTokens.stiraMuted)),
                            ],
                          ),
                        ),
                        const Text('🔥', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // ── Streak Trajectory Graph (amber) ─────────────────────
                  if (state.streakHistory.length > 1) ...[
                    staggerItem(2, StiraGlassCard(
                      accentColor: StiraTokens.stiraAmber,
                      fullWidth: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StiraCardLabel('STREAK TRAJECTORY'),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 120,
                            child: LineChart(
                              LineChartData(
                                minX: 0,
                                maxX: (state.streakHistory.length <= 5 
                                        ? 4 
                                        : state.streakHistory.length - 1).toDouble(),
                                minY: 0,
                                maxY: (state.streakHistory.reduce((a, b) => a > b ? a : b) + 5).toDouble(),
                                titlesData: const FlTitlesData(show: false),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                lineTouchData: const LineTouchData(enabled: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: state.streakHistory.asMap().entries.map((e) {
                                      // If history is small, space them out more reasonably.
                                      // Just map the last 5 if possible, or all.
                                      return FlSpot(e.key.toDouble(), e.value.toDouble());
                                    }).toList(),
                                    isCurved: true,
                                    curveSmoothness: 0.3,
                                    color: StiraTokens.stiraAmber,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          StiraTokens.stiraAmber.withValues(alpha: 0.3),
                                          StiraTokens.stiraAmber.withValues(alpha: 0.0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                  ],

                  // ── 7-day bar chart (violet) ────────────────────
                  staggerItem(state.streakHistory.length > 1 ? 3 : 2, StiraGlassCard(
                    accentColor: StiraTokens.stiraViolet,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const StiraCardLabel('URGE INTENSITY · 7 DAYS'),
                            const StiraInfoIcon(featureId: 'insights_chart'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 80,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: dayData.asMap().entries.map((e) {
                              final d = e.value;
                              final isToday = d['isToday'] as bool;
                              final intensity = d['intensity'] as double;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment:
                                              Alignment.bottomCenter,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeOutCubic,
                                            width: 18,
                                            height: 64 * intensity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius
                                                      .vertical(
                                                top: Radius.circular(4),
                                              ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: isToday
                                                    ? [
                                                        StiraTokens.stiraTeal,
                                                        StiraTokens.stiraTeal
                                                            .withValues(alpha: 0.3),
                                                      ]
                                                    : [
                                                        StiraTokens.stiraViolet,
                                                        StiraTokens.stiraViolet
                                                            .withValues(alpha: 0.3),
                                                      ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _dayInitial(d['weekday'] as int),
                                        style: GoogleFonts.dmMono(
                                          fontSize: 7,
                                          color: StiraTokens.stiraMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),



                  // ── Location Risk Map (amber) ───────────────────────
                  if (topLocationList.isNotEmpty)
                    staggerItem(state.streakHistory.length > 1 ? 5 : 4, StiraGlassCard(
                      accentColor: StiraTokens.stiraAmber,
                      fullWidth: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StiraCardLabel('LOCATION RISK MAP'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: topLocationList
                                .take(4)
                                .toList()
                                .asMap()
                                .entries
                                .map((e) {
                              final color = StiraTokens.stiraAmber;
                              final pct = totalLocations > 0
                                  ? ((e.value.value / totalLocations) * 100).round()
                                  : 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: color.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  '📍 ${e.value.key} $pct%',
                                  style: GoogleFonts.dmMono(
                                    fontSize: 10,
                                    color: color,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    )),
                  const SizedBox(height: 12),

                  // ── Hourly heatmap (teal) ───────────────────────
                  staggerItem(state.streakHistory.length > 1 ? 6 : 5, StiraGlassCard(
                    accentColor: StiraTokens.stiraTeal,
                    fullWidth: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const StiraCardLabel('MOST VULNERABLE HOURS'),
                            const StiraInfoIcon(featureId: 'insights_heatmap'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(24, (h) {
                            final vulnerabilityCount = state.hourlyVulnerability[h] ?? 0;
                            // Scale color based on count (max 5 for demo scaling)
                            final opacity = (0.15 + (vulnerabilityCount * 0.2)).clamp(0.15, 0.9);
                            final isHigh = vulnerabilityCount > 0;
                            
                            return Expanded(
                              child: Container(
                                height: isHigh ? 22 : 14,
                                margin: const EdgeInsets.symmetric(horizontal: 0.5),
                                decoration: BoxDecoration(
                                  color: isHigh
                                      ? StiraTokens.stiraPink.withOpacity(opacity)
                                      : StiraTokens.stiraTeal.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('12am',
                                style: GoogleFonts.dmMono(
                                    fontSize: 7,
                                    color: StiraTokens.stiraMuted)),
                            Text('12pm',
                                style: GoogleFonts.dmMono(
                                    fontSize: 7,
                                    color: StiraTokens.stiraMuted)),
                            Text('11pm',
                                style: GoogleFonts.dmMono(
                                    fontSize: 7,
                                    color: StiraTokens.stiraMuted)),
                          ],
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // ── Top triggers (pink) ─────────────────────────
                  if (topTriggerList.isNotEmpty)
                    staggerItem(state.streakHistory.length > 1 ? 7 : 6, StiraGlassCard(
                      accentColor: StiraTokens.stiraPink,
                      fullWidth: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const StiraCardLabel('TOP TRIGGERS'),
                              const StiraInfoIcon(featureId: 'top_triggers'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: topTriggerList
                                .take(4)
                                .toList()
                                .asMap()
                                .entries
                                .map((e) {
                              final color =
                                  triggerColors[e.key % triggerColors.length];
                              final pct = totalTriggers > 0
                                  ? ((e.value.value / totalTriggers) * 100)
                                      .round()
                                  : 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: color.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  '${e.value.key} $pct%',
                                  style: GoogleFonts.dmMono(
                                    fontSize: 10,
                                    color: color,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    )),
                  
                  // ── SCREEN TIME CORRELATION (pink) ───────────────────────
                  staggerItem(state.streakHistory.length > 1 ? 8 : 7, GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ScreenTimeScreen(),
                        ),
                      );
                    },
                    child: StiraGlassCard(
                      accentColor: StiraTokens.stiraPink,
                      fullWidth: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const StiraCardLabel('SCREEN TIME CORRELATION'),
                              const Spacer(),
                              Icon(Icons.chevron_right, color: StiraTokens.stiraMuted.withValues(alpha: 0.5), size: 16),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Analyze how your phone usage patterns trigger urges.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: StiraTokens.stiraWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),
                  
                  // ── DOPAMINE JOURNAL (violet) ───────────────────
                  staggerItem(state.streakHistory.length > 1 ? 9 : 8, GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const DopamineJournalScreen()),
                      );
                    },
                    child: StiraGlassCard(
                      accentColor: StiraTokens.stiraViolet,
                      fullWidth: true,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text('📔', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  const StiraCardLabel('DOPAMINE JOURNAL'),
                                ]),
                                const SizedBox(height: 8),
                                Text(
                                  'Track real-life rewards',
                                  style: GoogleFonts.syne(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: StiraTokens.stiraWhite,
                                  ),
                                ),
                                Text(
                                  'Log what gave you authentic joy today',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: StiraTokens.stiraMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 14,
                              color: StiraTokens.stiraViolet.withValues(alpha: 0.6)),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),
                  
                  // ── REWIRE MAP (teal) ───────────────────────────
                  staggerItem(state.streakHistory.length > 1 ? 10 : 9, GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => RewireMapScreen(state: state)),
                      );
                    },
                    child: StiraGlassCard(
                      accentColor: StiraTokens.stiraTeal,
                      fullWidth: true,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text('🗺️', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  const StiraCardLabel('REWIRE MAP'),
                                ]),
                                const SizedBox(height: 8),
                                Text(
                                  'Visualize your progress',
                                  style: GoogleFonts.syne(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: StiraTokens.stiraWhite,
                                  ),
                                ),
                                Text(
                                  'See how your brain is healing',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: StiraTokens.stiraMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 14,
                              color: StiraTokens.stiraTeal.withValues(alpha: 0.6)),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),

                  // ── Weekly Report CTA (violet) ──────────────────
                  staggerItem(state.streakHistory.length > 1 ? 11 : 10, GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => WeeklyReportScreen()),
                      );
                    },
                    child: StiraGlassCard(
                      accentColor: StiraTokens.stiraViolet,
                      fullWidth: true,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const StiraCardLabel('WEEKLY REPORT'),
                                    const StiraInfoIcon(featureId: 'weekly_report'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your full behavioral review',
                                  style: GoogleFonts.syne(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: StiraTokens.stiraViolet,
                                  ),
                                ),
                                Text(
                                  'Pattern analysis · Triggers · Forecast',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: StiraTokens.stiraMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 14,
                              color: StiraTokens.stiraViolet.withValues(alpha: 0.6)),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekRange(DateTime now) {
    final start = now.subtract(const Duration(days: 6));
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return 'WEEK OF ${months[start.month - 1]} ${start.day} – ${months[now.month - 1]} ${now.day}';
  }

  String _dayInitial(int weekday) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[weekday - 1];
  }
}
