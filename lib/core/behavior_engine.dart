import 'dart:math';
import 'dart:isolate';

enum VolatilityLevel { low, moderate, high }
enum Trend { improving, stable, worsening }

class ForecastWindow {
  final DateTime startTime;
  final DateTime endTime;
  const ForecastWindow({required this.startTime, required this.endTime});

  @override
  String toString() => '${startTime.hour.toString().padLeft(2, '0')}:00 - ${endTime.hour.toString().padLeft(2, '0')}:00';
}

class BehaviorProfile {
  final ForecastWindow? forecastWindow;
  final double forecastConfidence;
  final bool isolationAmplifier;
  final bool fatigueInfluence;
  final String? dominantTrigger;
  final VolatilityLevel volatilityLevel;
  final Trend recoveryTrend;

  const BehaviorProfile({
    required this.forecastWindow,
    required this.forecastConfidence,
    required this.isolationAmplifier,
    required this.fatigueInfluence,
    required this.dominantTrigger,
    required this.volatilityLevel,
    required this.recoveryTrend,
  });
}

class BehaviorEngine {
  /// Analyzes historical logs and returns a predictive profile.
  /// [logs] must contain check-ins ('timestamp', 'urge', 'alone', 'mood').
  /// [sleepHistory] maps format 'YYYY-M-D' to hours slept.
  /// [relapses] list of relapse DateTimes.
  static Future<BehaviorProfile> analyzeAsync(
    List<Map<String, dynamic>> logs,
    Map<String, int> sleepHistory,
    List<DateTime> relapses,
  ) {
    return Isolate.run(() => analyze(logs, sleepHistory, relapses));
  }

  static BehaviorProfile analyze(
    List<Map<String, dynamic>> logs,
    Map<String, int> sleepHistory,
    List<DateTime> relapses,
  ) {
    final now = DateTime.now();
    final cutoff14Days = now.subtract(const Duration(days: 14));
    
    // Filter to last 14 days
    final recentLogs = logs.where((l) {
      final tsStr = l['timestamp'] as String?;
      if (tsStr == null) return false;
      final dt = DateTime.tryParse(tsStr);
      if (dt == null) return false;
      return dt.isAfter(cutoff14Days);
    }).toList();

    // ── Time Density Detection ──
    ForecastWindow? forecastWindow;
    double forecastConfidence = 0.0;
    final elevatedLogs = recentLogs.where((l) => (l['urge'] as int? ?? 0) >= 7).toList();
    
    if (elevatedLogs.isNotEmpty) {
      final hourCounts = List.filled(24, 0);
      for (final log in elevatedLogs) {
        final dtStr = log['timestamp'] as String?;
        if (dtStr != null) {
          final dt = DateTime.parse(dtStr).toLocal();
          hourCounts[dt.hour]++;
        }
      }
      
      int maxClusterCount = 0;
      int clusterStartHour = 0;
      
      for (int i = 0; i < 24; i++) {
        final nextHour = (i + 1) % 24;
        final count = hourCounts[i] + hourCounts[nextHour];
        if (count > maxClusterCount) {
          maxClusterCount = count;
          clusterStartHour = i;
        }
      }
      
      forecastConfidence = maxClusterCount / elevatedLogs.length;

      // Forecast appears only if: ≥7 check-ins in last 14 days, ≥3 elevated events, Cluster density ≥45%.
      if (recentLogs.length >= 7 && elevatedLogs.length >= 3 && forecastConfidence >= 0.45) {
        final startDt = DateTime(now.year, now.month, now.day, clusterStartHour);
        final endDt = startDt.add(const Duration(hours: 2));
        forecastWindow = ForecastWindow(startTime: startDt, endTime: endDt);
      } else {
        forecastWindow = null;
      }
    }

    // ── Isolation Correlation ──
    bool isolationAmplifier = false;
    double aloneSum = 0;
    int aloneCount = 0;
    double groupedSum = 0;
    int groupedCount = 0;
    
    for (final log in recentLogs) {
      final urge = (log['urge'] as num?)?.toDouble() ?? 5.0;
      if (log['alone'] == true) {
        aloneSum += urge;
        aloneCount++;
      } else {
        groupedSum += urge;
        groupedCount++;
      }
    }
    
    if (aloneCount > 0 && groupedCount > 0) {
      final aloneAvg = aloneSum / aloneCount;
      final groupedAvg = groupedSum / groupedCount;
      if ((aloneAvg - groupedAvg) >= 1.5) {
        isolationAmplifier = true;
      }
    }

    // ── Fatigue Influence ──
    bool fatigueInfluence = false;
    double tiredSum = 0;
    int tiredCount = 0;
    double restedSum = 0;
    int restedCount = 0;

    for (final log in recentLogs) {
      final dtStr = log['timestamp'] as String?;
      if (dtStr == null) continue;
      final dt = DateTime.parse(dtStr).toLocal();
      final dateKey = '${dt.year}-${dt.month}-${dt.day}';
      final sleep = sleepHistory[dateKey];
      final urge = (log['urge'] as num?)?.toDouble() ?? 5.0;
      
      if (sleep != null) {
        if (sleep < 6) {
          tiredSum += urge;
          tiredCount++;
        } else {
          restedSum += urge;
          restedCount++;
        }
      }
    }

    if (tiredCount > 0 && restedCount > 0) {
      final tiredAvg = tiredSum / tiredCount;
      final restedAvg = restedSum / restedCount;
      if ((tiredAvg - restedAvg) >= 1.0) {
        fatigueInfluence = true;
      }
    }

    // ── Trigger Dominance ──
    String? dominantTrigger;
    if (elevatedLogs.isNotEmpty) {
      final moodCounts = <String, int>{};
      for (final log in elevatedLogs) {
        final mood = log['mood'] as String? ?? 'Unknown';
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      }
      
      var maxMood = '';
      var maxCount = 0;
      moodCounts.forEach((mood, count) {
        if (count > maxCount) {
          maxCount = count;
          maxMood = mood;
        }
      });
      
      if (maxCount >= (elevatedLogs.length * 0.4)) {
        dominantTrigger = maxMood;
      }
    }

    // ── Urge Volatility ──
    VolatilityLevel volatilityLevel = VolatilityLevel.low;
    // std deviation of last 7 urges
    final last7 = logs.reversed.take(7).toList();
    if (last7.length >= 3) {
      final urges = last7.map((l) => (l['urge'] as num?)?.toDouble() ?? 5.0).toList();
      final mean = urges.reduce((a, b) => a + b) / urges.length;
      final variance = urges.map((u) => pow(u - mean, 2)).reduce((a, b) => a + b) / urges.length;
      final stdDev = sqrt(variance);
      
      if (stdDev >= 2.5) {
        volatilityLevel = VolatilityLevel.high;
      } else if (stdDev >= 1.5) {
        volatilityLevel = VolatilityLevel.moderate;
      }
    }

    // ── Recovery Trend ──
    Trend recoveryTrend = Trend.stable;
    // Compare average recovery gap last 3 cycles vs previous 3.
    // Relapses are timestamps. Gap is days between relapses.
    if (relapses.length >= 6) {
      final sorted = List<DateTime>.from(relapses)..sort();
      final gaps = <double>[];
      for (int i = 1; i < sorted.length; i++) {
        gaps.add(sorted[i].difference(sorted[i-1]).inHours / 24.0);
      }
      
      final recent3 = gaps.reversed.take(3).toList();
      final prev3 = gaps.reversed.skip(3).take(3).toList();
      
      final recentAvg = recent3.reduce((a, b) => a + b) / 3;
      final prevAvg = prev3.reduce((a, b) => a + b) / 3;
      
      if (recentAvg >= prevAvg * 1.2) {
        recoveryTrend = Trend.improving;
      } else if (recentAvg <= prevAvg * 0.8) {
        recoveryTrend = Trend.worsening;
      }
    }

    return BehaviorProfile(
      forecastWindow: forecastWindow,
      forecastConfidence: forecastConfidence,
      isolationAmplifier: isolationAmplifier,
      fatigueInfluence: fatigueInfluence,
      dominantTrigger: dominantTrigger,
      volatilityLevel: volatilityLevel,
      recoveryTrend: recoveryTrend,
    );
  }
}
