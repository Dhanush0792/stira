import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../core/behavior_engine.dart';
import '../../services/local_storage.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  bool _isLoading = true;
  BehaviorProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final storage = StorageService();
    final logs = storage.getLogs();
    final sleepHistory = storage.getSleepHistory();
    final relapses = storage.getRelapseLogs();

    // Analyze data
    final profile = await BehaviorEngine.analyzeAsync(logs, sleepHistory, relapses);

    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: StiraTokens.stiraBg,
        body: const Center(
          child: CircularProgressIndicator(color: StiraTokens.stiraViolet),
        ),
      );
    }

    final profile = _profile!;
    
    // Derived UI values
    final String volatilityText = profile.volatilityLevel == VolatilityLevel.low 
        ? 'Your urge intensity remained remarkably stable this week.'
        : profile.volatilityLevel == VolatilityLevel.moderate
            ? 'Your urge intensity fluctuated moderately compared to last week.'
            : 'Your urge intensity showed high volatility this week.';
            
    final String driverText = profile.dominantTrigger != null
        ? '${profile.dominantTrigger} was the primary driver of elevated risks.'
        : 'No dominant emotional driver was identified this week.';

    final String trendSummary = profile.recoveryTrend == Trend.improving
        ? 'You are successfully breaking the isolation pattern by calling an ally when urges peak.'
        : profile.recoveryTrend == Trend.stable
            ? 'Your recovery baseline is holding steady. Stay vigilant during high-risk windows.'
            : 'Your resilience markers are slightly lower. Consider increasing your connection frequency.';

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Stability Report',
                            style: GoogleFonts.syne(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: StiraTokens.stiraWhite,
                            ),
                          ),
                          Text(
                            'Week of ${DateTime.now().subtract(const Duration(days: 7)).month}/${DateTime.now().subtract(const Duration(days: 7)).day} - ${DateTime.now().month}/${DateTime.now().day}',
                            style: GoogleFonts.dmMono(
                              fontSize: 11,
                              color: StiraTokens.stiraMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StiraGlassCard(
                          accentColor: StiraTokens.stiraViolet,
                          fullWidth: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: StiraTokens.stiraViolet, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI SUMMARY',
                                    style: GoogleFonts.dmMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: StiraTokens.stiraViolet,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Based on your recent logs, ${trendSummary.toLowerCase().startsWith('you') ? trendSummary : trendSummary}',
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

                        Text(
                          'KEY INSIGHTS',
                          style: GoogleFonts.dmMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: StiraTokens.stiraMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _ReportCard(
                          title: 'Volatility Shift',
                          content: volatilityText,
                          icon: profile.volatilityLevel == VolatilityLevel.low ? Icons.trending_down : Icons.trending_flat,
                          isPositive: profile.volatilityLevel == VolatilityLevel.low,
                        ),
                        const SizedBox(height: 16),

                        _ReportCard(
                          title: 'Dominant Driver Analysis',
                          content: driverText,
                          icon: Icons.psychology_outlined,
                          isPositive: profile.dominantTrigger == null,
                        ),
                        const SizedBox(height: 16),

                        _ReportCard(
                          title: 'Recovery Marker',
                          content: profile.recoveryTrend == Trend.improving 
                            ? 'Your recovery intervals are lengthening by 20%.'
                            : profile.recoveryTrend == Trend.stable
                                ? 'Your recovery intensity is within normal ranges.'
                                : 'Recovery gaps have decreased slightly.',
                          icon: Icons.shield_outlined,
                          isPositive: profile.recoveryTrend != Trend.worsening,
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            'This intelligence is strictly private and stored offline.',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: StiraTokens.stiraMuted.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
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

class _ReportCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isPositive;

  const _ReportCard({
    required this.title,
    required this.content,
    required this.icon,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? StiraTokens.stiraTeal : StiraTokens.stiraViolet;
    
    return StiraGlassCard(
      accentColor: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.syne(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: StiraTokens.stiraWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: StiraTokens.stiraMuted,
                    height: 1.4,
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
