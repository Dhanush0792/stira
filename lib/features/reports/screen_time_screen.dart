import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_card_label.dart';
import '../../core/intelligence_layer.dart';
import '../../services/local_storage.dart';

import '../../services/screen_time_service.dart';
import '../../services/stira_haptic_service.dart';

// Real Provider for Screen Time (Today only)
final screenTimeDataProvider = FutureProvider<Map<String, double>>((ref) async {
  return ScreenTimeService().getTodayUsageStats();
});

// Hourly segments for the graph
final screenTimeSegmentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ScreenTimeService().getHourlyUsageSegments();
});

// Real check-in logs for urge trend
final checkinLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return StorageService().getLogs();
});

final screenTimePermissionProvider = StateProvider<bool>((ref) => false);

class ScreenTimeScreen extends ConsumerStatefulWidget {
  const ScreenTimeScreen({super.key});

  @override
  ConsumerState<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends ConsumerState<ScreenTimeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh all data when user returns from settings or another app
      ref.invalidate(screenTimeDataProvider);
      ref.invalidate(screenTimeSegmentsProvider);
      ref.invalidate(checkinLogsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usageAsync = ref.watch(screenTimeDataProvider);
    final segmentsAsync = ref.watch(screenTimeSegmentsProvider);
    final logsAsync = ref.watch(checkinLogsProvider);
    final intelligence = ref.watch(intelligenceProvider);

    // Merge real hourly segments with real urge logs
    final List<Map<String, dynamic>> dataPoints = segmentsAsync.maybeWhen(
      data: (segments) {
        final logs = logsAsync.maybeWhen(data: (l) => l, orElse: () => <Map<String, dynamic>>[]);
        
        return segments.map((seg) {
          final hour = seg['hour'] as int;
          
          // Find max urge for this hour from logs
          final now = DateTime.now();
          int maxUrge = 1; // Baseline
          
          for (final log in logs) {
            final tsStr = log['timestamp'] as String?;
            if (tsStr == null) continue;
            final dt = DateTime.tryParse(tsStr);
            if (dt == null) continue;
            
            // If log is from today and matches this hour
            if (dt.year == now.year && dt.month == now.month && dt.day == now.day && dt.hour == hour) {
              final urge = log['urge'] as int? ?? 0;
              if (urge > maxUrge) maxUrge = urge;
            }
          }
          
          return {
            'hour': hour,
            'screenTime': seg['screenTime'],
            'urge': maxUrge,
          };
        }).toList();
      },
      orElse: () => [],
    );

    // Check if total usage > 6h as a proxy for doomscrolling risk
    final isDoomscrolling = usageAsync.maybeWhen(
      data: (data) => (data['totalHours'] ?? 0) > 6.0,
      orElse: () => false,
    );

    final hasPermission = usageAsync.maybeWhen(
      data: (data) => data['totalHours'] != 0 || data['socialHours'] != 0,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Background Glow
          if (isDoomscrolling && hasPermission)
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
                      StiraTokens.stiraPink.withValues(alpha: 0.15),
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
                        'Screen Time & Urge',
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
                        // Doomscrolling Risk Indicator
                        StiraGlassCard(
                          accentColor: isDoomscrolling && hasPermission ? StiraTokens.stiraPink : StiraTokens.stiraTeal,
                          fullWidth: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isDoomscrolling && hasPermission ? Icons.warning_rounded : Icons.check_circle_outline,
                                    color: isDoomscrolling && hasPermission ? StiraTokens.stiraPink : StiraTokens.stiraTeal,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isDoomscrolling && hasPermission ? 'DOOMSCROLLING RISK' : 'HEALTHY USAGE',
                                    style: GoogleFonts.dmMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDoomscrolling && hasPermission ? StiraTokens.stiraPink : StiraTokens.stiraTeal,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text( // Fixed style argument formatting
                                !hasPermission
                                  ? 'Usage stats inactive. Grant access to analyze your patterns.'
                                  : isDoomscrolling 
                                    ? 'High screen time on social media is currently preceding your highest urge spikes. Consider a physical reset.'
                                    : 'Your screen time is balanced and not showing high correlation with urges today.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: StiraTokens.stiraWhite,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Permission Request if needed
                        if (!hasPermission)
                          StiraGlassCard(
                            accentColor: StiraTokens.stiraAmber,
                            fullWidth: true,
                            child: Column(
                              children: [
                                const StiraCardLabel('NATIVE STATS INACTIVE'),
                                const SizedBox(height: 12),
                                Text(
                                  'Grant usage access to see your real behavior patterns.',
                                  style: GoogleFonts.dmSans(fontSize: 13, color: StiraTokens.stiraWhite),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: StiraTokens.stiraAmber.withValues(alpha: 0.2),
                                    foregroundColor: StiraTokens.stiraWhite,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () async {
                                    await ScreenTimeService().requestPermission();
                                    ref.invalidate(screenTimeDataProvider);
                                  },
                                  child: const Text('Grant Access'),
                                ),
                              ],
                            ),
                          ),
                        
                        if (hasPermission) ...[
                          const SizedBox(height: 12),

                          // Stats Summary
                          Row(
                            children: [
                              Expanded(
                                child: StiraGlassCard(
                                  accentColor: StiraTokens.stiraAmber,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const StiraCardLabel('TOTAL SCREEN TIME'),
                                      const SizedBox(height: 8),
                                      usageAsync.when(
                                        data: (data) => Text(
                                          '${data['totalHours']?.toStringAsFixed(1)}h',
                                          style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.bold, color: StiraTokens.stiraWhite),
                                        ),
                                        loading: () => const CircularProgressIndicator(strokeWidth: 2),
                                        error: (_, __) => const Text('Error'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StiraGlassCard(
                                  accentColor: StiraTokens.stiraViolet,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const StiraCardLabel('SOCIAL MEDIA'),
                                      const SizedBox(height: 8),
                                      usageAsync.when(
                                        data: (data) => Text(
                                          '${data['socialHours']?.toStringAsFixed(1)}h',
                                          style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.bold, color: StiraTokens.stiraViolet),
                                        ),
                                        loading: () => const SizedBox(height: 24),
                                        error: (_, __) => const Text('Error'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Graph Section
                          Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Usage vs Urge Intensity',
                                    style: GoogleFonts.syne(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: StiraTokens.stiraWhite,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bars = Screen Time (mins) · Line = Urge Level',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: StiraTokens.stiraMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // FlChart for Bar + Line Combo
                                  // Bug Fix #4: Compute maxY dynamically so bars never overflow
                                  SizedBox(
                                    height: 250,
                                    child: Builder(
                                      builder: (context) {
                                        // Compute dynamic maxY: at least 60 min, 20% headroom
                                        final maxScreenTime = dataPoints.isEmpty
                                            ? 60
                                            : dataPoints
                                                .map((d) => d['screenTime'] as int)
                                                .reduce(max);
                                        final dynamicMaxY = max(60, (maxScreenTime * 1.25).ceil()).toDouble();

                                        return BarChart(
                                      BarChartData(
                                          alignment: BarChartAlignment.spaceAround,
                                          maxY: dynamicMaxY,
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchCallback: (FlTouchEvent event, barTouchResponse) {
                                            if (!event.isInterestedForInteractions ||
                                                barTouchResponse == null ||
                                                barTouchResponse.spot == null) {
                                              return;
                                            }
                                            // Haptic feedback on touch
                                            HapticFeedback.lightImpact();
                                          },
                                          touchTooltipData: BarTouchTooltipData(
                                            getTooltipColor: (_) => StiraTokens.stiraBg.withValues(alpha: 0.8),
                                            tooltipBorder: BorderSide(color: StiraTokens.stiraWhite.withValues(alpha: 0.1)),
                                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                              return BarTooltipItem(
                                                '${rod.toY.toInt()} min',
                                                GoogleFonts.dmMono(color: StiraTokens.stiraWhite, fontSize: 10),
                                              );
                                            },
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                final i = value.toInt();
                                                if (i >= 0 && i < dataPoints.length) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Text(
                                                      '${dataPoints[i]['hour']}h',
                                                      style: GoogleFonts.dmMono(
                                                        fontSize: 10,
                                                        color: StiraTokens.stiraMuted,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox();
                                              },
                                              reservedSize: 28,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              getTitlesWidget: (value, meta) {
                                                if (value % (dynamicMaxY / 3).ceil() == 0 || value == 0) {
                                                  return Text(
                                                    '${value.toInt()}m',
                                                    style: GoogleFonts.dmMono(
                                                      fontSize: 10,
                                                      color: StiraTokens.stiraMuted,
                                                    ),
                                                  );
                                                }
                                                return const SizedBox();
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          horizontalInterval: 50,
                                          getDrawingHorizontalLine: (value) => FlLine(
                                            color: StiraTokens.stiraGlassBorder,
                                            strokeWidth: 1,
                                          ),
                                          drawVerticalLine: false,
                                        ),
                                        borderData: FlBorderData(show: false),
                                          barGroups: List.generate(dataPoints.length, (i) {
                                            // Clamp to dynamicMaxY to prevent bars from overflowing
                                            final time = (dataPoints[i]['screenTime'] as int).toDouble();
                                            final clampedTime = time.clamp(0, dynamicMaxY).toDouble();
                                            return BarChartGroupData(
                                              x: i,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: clampedTime,
                                                  color: StiraTokens.stiraViolet.withValues(alpha: 0.7),
                                                  width: 16,
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                        swapAnimationDuration: const Duration(milliseconds: 500),
                                      );
                                    }),
                                  ),
                                  // Overlay Line Chart for Urges (on the same axes space, but scaled)
                                  // This is a simpler way to represent dual charts in FlChart without complex combo charts
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 100,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: LineChart(
                                            LineChartData(
                                              minY: 0,
                                              maxY: 10,
                                              lineTouchData: LineTouchData(
                                                enabled: true,
                                                touchCallback: (event, response) {
                                                  if (event is FlPanDownEvent || event is FlTapDownEvent) {
                                                    HapticFeedback.selectionClick();
                                                  }
                                                },
                                              ),
                                              titlesData: FlTitlesData(
                                                show: true,
                                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              ),
                                              gridData: const FlGridData(show: false),
                                              borderData: FlBorderData(show: false),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: List.generate(dataPoints.length, (i) {
                                                    return FlSpot(i.toDouble(), (dataPoints[i]['urge'] as int).toDouble());
                                                  }),
                                                  isCurved: true,
                                                  color: StiraTokens.stiraPink,
                                                  barWidth: 3,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter: (spot, percent, barData, index) {
                                                      return FlDotCirclePainter(
                                                        radius: 4,
                                                        color: StiraTokens.stiraPink,
                                                        strokeWidth: 2,
                                                        strokeColor: StiraTokens.stiraBg,
                                                      );
                                                    },
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    color: StiraTokens.stiraPink.withValues(alpha: 0.1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'Urge Intensity Line Trend',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: StiraTokens.stiraPink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
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
