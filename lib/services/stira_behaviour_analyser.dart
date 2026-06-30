import 'package:hive/hive.dart';

// Output model — all signals in one object
class BehaviourSnapshot {
  final int currentStreak;
  final int hoursSinceLastCheckIn;
  final double avgUrgeIntensityLast7Days;
  final double urgeVelocity;          // positive = rising, negative = falling
  final int peakHour;                 // 0-23: hour with most high-intensity check-ins
  final int peakHourConfidence;       // 0-100: how confident the peak hour prediction is
  final String topTrigger;            // "Boredom", "Stress", etc.
  final bool checkedInToday;
  final bool dopamineJournalToday;
  final bool isInRestMode;
  final int sentToday;
  final DateTime? lastSentAt;
  final double stabilityTrend;        // positive = improving, negative = declining
  final int totalCleanDays;
  final String userName;
  final String coreNeed;
  final int daysSinceInstall;
  final bool sameTimeTomorrowDue;
  final String sameTimeTomorrowCommitment;
  final DateTime? lastRelapseAt;

  const BehaviourSnapshot({
    required this.currentStreak,
    required this.hoursSinceLastCheckIn,
    required this.avgUrgeIntensityLast7Days,
    required this.urgeVelocity,
    required this.peakHour,
    required this.peakHourConfidence,
    required this.topTrigger,
    required this.checkedInToday,
    required this.dopamineJournalToday,
    required this.isInRestMode,
    required this.sentToday,
    required this.lastSentAt,
    required this.stabilityTrend,
    required this.totalCleanDays,
    required this.userName,
    required this.coreNeed,
    required this.daysSinceInstall,
    required this.sameTimeTomorrowDue,
    required this.sameTimeTomorrowCommitment,
    required this.lastRelapseAt,
  });
}

class StiraBehaviourAnalyser {
  static BehaviourSnapshot analyse() {
    final checkIns    = Hive.box('check_ins');
    final userData    = Hive.box('user_data');
    final notifState  = Hive.box('notification_state');
    final journal     = Hive.box('dopamine_journal');
    final commitments = Hive.box('commitments');

    // ─── Basic user data ───
    final String userName   = userData.get('name', defaultValue: 'there');
    final String coreNeed   = userData.get('core_need', defaultValue: 'Calm');
    final int currentStreak = userData.get('current_streak', defaultValue: 0);
    final int totalCleanDays= userData.get('total_clean_days', defaultValue: 0);

    final DateTime installDate = DateTime.parse(userData.get('install_date',
        defaultValue: DateTime.now().toIso8601String()));
    final int daysSinceInstall = DateTime.now().difference(installDate).inDays;

    // ─── Last relapse ───
    final String? lastRelapseStr = userData.get('last_relapse_at');
    final DateTime? lastRelapseAt = lastRelapseStr != null
        ? DateTime.tryParse(lastRelapseStr) : null;

    // ─── Check-in history (last 30 days) ───
    final now = DateTime.now();
    final allCheckIns = checkIns.values
        .cast<Map>().toList()
        .where((c) {
          final tsStr = c['timestamp'] as String?;
          if (tsStr == null) return false;
          final ts = DateTime.tryParse(tsStr);
          return ts != null && now.difference(ts).inDays <= 30;
        })
        .toList()
        ..sort((a, b) {
          final ta = DateTime.parse(a['timestamp'] as String);
          final tb = DateTime.parse(b['timestamp'] as String);
          return tb.compareTo(ta); // newest first
        });

    // ─── Hours since last check-in ───
    int hoursSinceLastCheckIn = 999;
    if (allCheckIns.isNotEmpty) {
      final last = DateTime.parse(allCheckIns.first['timestamp'] as String);
      hoursSinceLastCheckIn = now.difference(last).inHours;
    }

    // ─── Checked in today ───
    final bool checkedInToday = allCheckIns.any((c) {
      final ts = DateTime.parse(c['timestamp'] as String);
      return ts.day == now.day && ts.month == now.month && ts.year == now.year;
    });

    // ─── Average urge intensity last 7 days ───
    final last7 = allCheckIns.where((c) {
      final ts = DateTime.parse(c['timestamp'] as String);
      return now.difference(ts).inDays <= 7;
    }).toList();

    final double avgUrge = last7.isEmpty ? 0 :
        last7.map((c) => (c['urge_level'] as num).toDouble())
        .reduce((a, b) => a + b) / last7.length;

    // ─── Urge velocity: compare last 3 check-ins ───
    double urgeVelocity = 0;
    if (allCheckIns.length >= 3) {
      final levels = allCheckIns.take(3).map((c) => (c['urge_level'] as num).toDouble()).toList();
      urgeVelocity = levels[0] - levels[2]; // newest minus oldest of 3
    }

    // ─── Peak hour: find the hour with most high-intensity (>=6) check-ins ───
    final Map<int, int> hourCounts = {};
    for (final c in allCheckIns) {
      if ((c['urge_level'] as num) >= 6) {
        final hour = DateTime.parse(c['timestamp'] as String).hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    int peakHour = 21; // default: 9 PM
    int peakCount = 0;
    hourCounts.forEach((h, count) {
      if (count > peakCount) { peakCount = count; peakHour = h; }
    });

    // Confidence: how many data points support this peak
    final int peakHourConfidence = (peakCount / (last7.length + 1) * 100).clamp(0, 100).toInt();

    // ─── Top trigger ───
    final Map<String, int> triggerCounts = {};
    for (final c in allCheckIns) {
      final triggers = List<String>.from(c['triggers'] ?? []);
      for (final t in triggers) {
        triggerCounts[t] = (triggerCounts[t] ?? 0) + 1;
      }
    }

    String topTrigger = 'Stress';
    int topCount = 0;
    triggerCounts.forEach((t, count) {
      if (count > topCount) { topCount = count; topTrigger = t; }
    });

    // ─── Stability trend: compare avg intensity week1 vs week2 ───
    final week1 = allCheckIns.where((c) {
      final d = now.difference(DateTime.parse(c['timestamp'] as String)).inDays;
      return d <= 7;
    }).toList();

    final week2 = allCheckIns.where((c) {
      final d = now.difference(DateTime.parse(c['timestamp'] as String)).inDays;
      return d > 7 && d <= 14;
    }).toList();

    double stabilityTrend = 0;
    if (week1.isNotEmpty && week2.isNotEmpty) {
      final avg1 = week1.map((c) => (c['urge_level'] as num).toDouble()).reduce((a,b)=>a+b)/week1.length;
      final avg2 = week2.map((c) => (c['urge_level'] as num).toDouble()).reduce((a,b)=>a+b)/week2.length;
      stabilityTrend = avg2 - avg1; // positive = getting worse, negative = improving
    }

    // ─── Dopamine journal today ───
    final bool dopamineJournalToday = journal.values.any((j) {
      if (j is! Map) return false;
      final tsStr = j['date'] as String?;
      if (tsStr == null) return false;
      final ts = DateTime.tryParse(tsStr);
      return ts != null && ts.day == now.day && ts.month == now.month;
    });

    // ─── Notification state ───
    final int sentToday = notifState.get('sent_today', defaultValue: 0);
    final bool isInRestMode = notifState.get('rest_mode', defaultValue: false);
    final String? lastSentStr = notifState.get('last_sent_at');
    final DateTime? lastSentAt = lastSentStr != null ? DateTime.tryParse(lastSentStr) : null;

    // ─── Same Time Tomorrow commitment ───
    bool sameTimeTomorrowDue = false;
    String sameTimeTomorrowCommitment = '';
    if (commitments.isNotEmpty) {
      final recent = commitments.values.last as Map?;
      if (recent != null) {
        final savedAtStr = recent['saved_at'] as String?;
        final savedAt = savedAtStr != null ? DateTime.tryParse(savedAtStr) : null;
        if (savedAt != null) {
          final hoursDiff = now.difference(savedAt).inHours;
          if (hoursDiff >= 23 && hoursDiff <= 25 && recent['outcome'] == null) {
            sameTimeTomorrowDue = true;
            sameTimeTomorrowCommitment = recent['commitment'] as String? ?? '';
          }
        }
      }
    }

    return BehaviourSnapshot(
      currentStreak: currentStreak,
      hoursSinceLastCheckIn: hoursSinceLastCheckIn,
      avgUrgeIntensityLast7Days: avgUrge,
      urgeVelocity: urgeVelocity,
      peakHour: peakHour,
      peakHourConfidence: peakHourConfidence,
      topTrigger: topTrigger,
      checkedInToday: checkedInToday,
      dopamineJournalToday: dopamineJournalToday,
      isInRestMode: isInRestMode,
      sentToday: sentToday,
      lastSentAt: lastSentAt,
      stabilityTrend: stabilityTrend,
      totalCleanDays: totalCleanDays,
      userName: userName,
      coreNeed: coreNeed,
      daysSinceInstall: daysSinceInstall,
      sameTimeTomorrowDue: sameTimeTomorrowDue,
      sameTimeTomorrowCommitment: sameTimeTomorrowCommitment,
      lastRelapseAt: lastRelapseAt,
    );
  }

  // ─── REAL-TIME: call this whenever the user does something in the app ───
  static void syncToHive({
    required int currentStreak,
    required int urgeLevel,
    required List<String> triggers,
    required String location,
  }) {
    final checkIns = Hive.box('check_ins');
    checkIns.add({
      'timestamp': DateTime.now().toIso8601String(),
      'urge_level': urgeLevel,
      'triggers': triggers,
      'location': location,
    });

    final userData = Hive.box('user_data');
    userData.put('current_streak', currentStreak);
    userData.put('last_checkin_at', DateTime.now().toIso8601String());
  }
}
