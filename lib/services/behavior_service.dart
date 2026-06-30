import 'local_storage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

/// Result of the urge forecast analysis.
class ForecastResult {
  /// The 4-character label for the peak window.
  final String label; // e.g. "Late evening"
  /// Soft contextual sentence shown on dashboard.
  final String subtitle; // e.g. "Late evening may feel heavier."
  /// Hour index (0–23) at start of the peak window.
  final int peakHour;

  const ForecastResult({
    required this.label,
    required this.subtitle,
    required this.peakHour,
  });
}

/// Pattern detected from logs, shown as a reflection card.
class ReflectionInsight {
  final String text; // Always soft-worded with "may/often/appears"

  const ReflectionInsight(this.text);
}

// ─────────────────────────────────────────────────────────────────────────────
// BehaviorService
// Pure logic only — no Flutter imports, no UI, no side-effects.
// ─────────────────────────────────────────────────────────────────────────────

class BehaviorService {
  final StorageService _storage;

  BehaviorService([StorageService? storage])
      : _storage = storage ?? StorageService();

  // ── 1. Urge Forecast ───────────────────────────────────────────────────────

  /// Analyses relapse + check-in log timestamps to identify the most
  /// frequently difficult time window.  Falls back to the onboarding
  /// window when fewer than 3 data points exist.
  ForecastResult buildForecast() {
    final logs = _storage.getLogs();
    final relapseDates = _storage.getRelapseLogs();

    // Combine all timestamps that had elevated events
    final hours = <int>[];
    for (final log in logs) {
      final ts = log['timestamp'] as String?;
      if (ts == null) continue;
      final dt = DateTime.tryParse(ts);
      if (dt == null) continue;
      final urge = (log['urge'] as num?)?.toInt() ?? 0;
      if (urge >= 7) hours.add(dt.hour); // only high-urge moments
    }
    for (final r in relapseDates) {
      hours.add(r.hour);
    }

    ForecastResult result;

    // Need at least 3 data points; otherwise use profile window
    if (hours.length < 3) {
      result = _forecastFromProfileWindow();
    } else {
      // Cluster into 4 buckets
      final bucket = _dominantBucket(hours);
      result = _bucketToForecast(bucket);
    }

    // Correlate with biometrics
    final sleepHours = _storage.getTodaySleep();
    if (sleepHours != null && sleepHours < 6) {
      return ForecastResult(
        label: result.label,
        subtitle: 'Your physical resilience is lower today due to lack of rest.',
        peakHour: result.peakHour,
      );
    }

    return result;
  }

  ForecastResult _forecastFromProfileWindow() {
    final profile = _storage.getProfile();
    final window =
        (profile?['window'] as String? ?? 'Late night').toLowerCase();
    if (window.contains('morning')) return _bucketToForecast(0);
    if (window.contains('afternoon')) return _bucketToForecast(1);
    if (window.contains('evening')) return _bucketToForecast(2);
    return _bucketToForecast(3);
  }

  /// Returns 0=morning, 1=afternoon, 2=evening, 3=late-night
  int _dominantBucket(List<int> hours) {
    final counts = [0, 0, 0, 0];
    for (final h in hours) {
      if (h >= 6 && h < 12) {
        counts[0]++;
      } else if (h >= 12 && h < 18) {
        counts[1]++;
      } else if (h >= 18 && h < 22) {
        counts[2]++;
      } else {
        counts[3]++;
      }
    }
    int best = 0;
    for (int i = 1; i < 4; i++) {
      if (counts[i] > counts[best]) { best = i; }
    }
    return best;
  }

  ForecastResult _bucketToForecast(int bucket) {
    switch (bucket) {
      case 0:
        return const ForecastResult(
          label: 'Morning',
          subtitle: 'Morning hours may feel heavier.',
          peakHour: 8,
        );
      case 1:
        return const ForecastResult(
          label: 'Afternoon',
          subtitle: 'Afternoon may bring stronger urges.',
          peakHour: 14,
        );
      case 2:
        return const ForecastResult(
          label: 'Evening',
          subtitle: 'Evening may feel heavier.',
          peakHour: 19,
        );
      default:
        return const ForecastResult(
          label: 'Late evening',
          subtitle: 'Late evening may feel heavier.',
          peakHour: 22,
        );
    }
  }

  // ── Bucket helpers ─────────────────────────────────────────────────────────

  /// Which bucket (0–3) does a given hour fall into?
  static int hourToBucket(int hour) {
    if (hour >= 6 && hour < 12) return 0;
    if (hour >= 12 && hour < 18) return 1;
    if (hour >= 18 && hour < 22) return 2;
    return 3;
  }

  // ── 2. Pattern Reflection ──────────────────────────────────────────────────

  /// Returns a soft-worded reflection if a pattern can be detected.
  /// Returns null if there is insufficient data.
  ReflectionInsight? buildReflection() {
    final logs = _storage.getLogs();
    final relapseLogs = _storage.getRelapseLogs();

    final totalRelapses = relapseLogs.length;
    final totalCheckins = logs.length;

    // Only surface when we have enough data
    if (totalRelapses < 3 && totalCheckins < 7) return null;

    // Analyse last 5 check-in logs
    final recent = logs.length > 5 ? logs.sublist(logs.length - 5) : logs;
    if (recent.isEmpty) return null;

    // Count triggers
    final triggerCount = <String, int>{};
    final highUrgeHours = <int>[];

    for (final log in recent) {
      final mood = (log['mood'] as String?) ?? '';
      if (mood.isNotEmpty) triggerCount[mood] = (triggerCount[mood] ?? 0) + 1;
      final ts = log['timestamp'] as String?;
      final urge = (log['urge'] as num?)?.toInt() ?? 0;
      if (ts != null && urge >= 7) {
        final dt = DateTime.tryParse(ts);
        if (dt != null) highUrgeHours.add(dt.hour);
      }
    }

    // Find dominant trigger (≥ 2 appearances out of 5)
    String? dominantMood;
    int maxCount = 0;
    triggerCount.forEach((k, v) {
      if (v > maxCount) {
        maxCount = v;
        dominantMood = k;
      }
    });
    if (maxCount < 2) dominantMood = null;

    // Find dominant high-urge time window
    String? timeLabel;
    if (highUrgeHours.isNotEmpty) {
      final bucket = _dominantBucket(highUrgeHours);
      timeLabel =
          ['mornings', 'afternoons', 'evenings', 'late evenings'][bucket];
    }

    // Build soft insight
    if (dominantMood != null && timeLabel != null) {
      return ReflectionInsight(
        'You may often experience higher urges when feeling $dominantMood during $timeLabel.',
      );
    } else if (dominantMood != null) {
      return ReflectionInsight(
        'Feeling $dominantMood appears to often coincide with stronger urges.',
      );
    } else if (timeLabel != null) {
      return ReflectionInsight(
        'Stronger urges may often appear during $timeLabel for you.',
      );
    }

    return null;
  }

  // ── 3. Stability Index ─────────────────────────────────────────────────────

  /// Calculates a 0–100 stability index.
  ///
  /// check-in consistency  : up to 40 pts (4 pts per check-in, max 10)
  /// reduced elevated risk : up to 40 pts (starts at 40, -8 per elevated event)
  /// streak gap            : up to 20 pts (2 pts per steady day, cap at 10 days)
  int calculateStabilityIndex() {
    final logs = _storage.getLogs();
    final elevatedCount = _storage.elevatedRiskCount;
    final streakDays = _storage.calculateStreak();

    final checkInScore = (logs.length * 4).clamp(0, 40);
    final riskScore = (40 - elevatedCount * 8).clamp(0, 40);
    final gapScore = (streakDays * 2).clamp(0, 20);

    return (checkInScore + riskScore + gapScore).clamp(0, 100);
  }

  // ── 4. Micro-message ───────────────────────────────────────────────────────

  /// Returns the appropriate micro-affirmation for a given risk level.
  static String microMessage(String riskLevelName) {
    switch (riskLevelName) {
      case 'low':
        return 'You handled this moment.';
      case 'moderate':
        return 'Steady progress.';
      case 'elevated':
        return 'You stayed steady.';
      default:
        return 'Awareness is the first step.';
    }
  }
}
