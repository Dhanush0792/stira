import 'package:hive_flutter/hive_flutter.dart';

class StiraBehaviourSnapshot {
  final String userName;
  final int currentStreak;
  final int totalCleanDays;
  final int hoursSinceLastCheckIn;
  final bool checkedInToday;
  final int sentToday;
  final DateTime? lastSentAt;
  final bool restMode;
  final bool dopamineJournalToday;
  final int peakHour;
  final int peakHourConfidence;
  final double urgeVelocity;
  final String topTrigger;
  final double stabilityTrend;
  final String coreNeed;
  final bool sameTimeTomorrowDue;
  final String commitmentText;
  final DateTime? lastRelapseAt;
  final int daysSinceInstall;
  final int personalBestStreak;

  const StiraBehaviourSnapshot({
    required this.userName,
    required this.currentStreak,
    required this.totalCleanDays,
    required this.hoursSinceLastCheckIn,
    required this.checkedInToday,
    required this.sentToday,
    required this.lastSentAt,
    required this.restMode,
    required this.dopamineJournalToday,
    required this.peakHour,
    required this.peakHourConfidence,
    required this.urgeVelocity,
    required this.topTrigger,
    required this.stabilityTrend,
    required this.coreNeed,
    required this.sameTimeTomorrowDue,
    required this.commitmentText,
    required this.lastRelapseAt,
    required this.daysSinceInstall,
    required this.personalBestStreak,
  });
}

class StiraBehaviourReader {
  static StiraBehaviourSnapshot snapshot() {
    final prefs = Hive.box('stira_prefs');
    final userData = Hive.box('user_data');
    final checkIns = Hive.box('check_ins');
    final journal = Hive.box('dopamine_journal');
    final commitments = Hive.box('commitments');

    final now = DateTime.now();

    // -- Prefs / User Data --
    final String userName = userData.get('name', defaultValue: 'there');
    final int currentStreak = userData.get('current_streak', defaultValue: 0);
    final int totalCleanDays = userData.get('total_clean_days', defaultValue: 0);
    final int personalBestStreak = userData.get('longest_streak', defaultValue: 0);
    final String coreNeed = userData.get('core_need', defaultValue: 'Calm');
    
    final String? installDateStr = userData.get('install_date');
    DateTime installDate = installDateStr != null ? DateTime.parse(installDateStr) : now;
    final int daysSinceInstall = now.difference(installDate).inDays;

    final String? lastCheckinStr = userData.get('last_checkin_at');
    DateTime? lastCheckin = lastCheckinStr != null ? DateTime.tryParse(lastCheckinStr) : null;
    
    int hoursSinceLastCheckIn = 999;
    bool checkedInToday = false;
    if (lastCheckin != null) {
      hoursSinceLastCheckIn = now.difference(lastCheckin).inHours;
      checkedInToday = lastCheckin.year == now.year && lastCheckin.month == now.month && lastCheckin.day == now.day;
    }

    // -- Relapse --
    final String? lastRelapseStr = userData.get('last_relapse_at') ?? prefs.get('last_relapse_date');
    DateTime? lastRelapseAt = lastRelapseStr != null ? DateTime.tryParse(lastRelapseStr) : null;

    // -- Throttle Data (from prefs as instructed) --
    final int sentToday = prefs.get('sentToday', defaultValue: 0);
    final String? lastSentStr = prefs.get('lastSentAt');
    DateTime? lastSentAt = lastSentStr != null ? DateTime.tryParse(lastSentStr) : null;
    
    final String? restModeUntilStr = prefs.get('rest_mode_until');
    bool restMode = false;
    if (restModeUntilStr != null) {
      final restModeUntil = DateTime.tryParse(restModeUntilStr);
      if (restModeUntil != null && restModeUntil.isAfter(now)) {
        restMode = true;
      }
    }

    // -- Dopamine Journal --
    bool dopamineJournalToday = false;
    for (var j in journal.values) {
      if (j is Map) {
        final dateStr = j['date'] as String?;
        if (dateStr != null) {
          final d = DateTime.tryParse(dateStr);
          if (d != null && d.year == now.year && d.month == now.month && d.day == now.day) {
            dopamineJournalToday = true;
            break;
          }
        }
      }
    }

    // -- Same Time Tomorrow --
    bool sameTimeTomorrowDue = false;
    String commitmentText = '';
    
    if (commitments.isNotEmpty) {
      final recent = commitments.values.last as Map?;
      if (recent != null) {
        final savedAtStr = recent['saved_at'] as String? ?? recent['timestamp'] as String?;
        if (savedAtStr != null) {
          final savedAt = DateTime.tryParse(savedAtStr);
          if (savedAt != null) {
            final int hoursDiff = now.difference(savedAt).inHours;
            if (hoursDiff >= 23 && hoursDiff <= 25 && recent['outcome'] == null) {
              sameTimeTomorrowDue = true;
              commitmentText = recent['text'] as String? ?? recent['commitment'] as String? ?? '';
            }
          }
        }
      }
    }

    // -- Check-in History Calculations --
    final allCheckIns = checkIns.values.cast<Map>().toList();
    // Sort oldest to newest for chronological tracking, wait prompt says "sorted by timestamp descending" for urgeVelocity
    allCheckIns.sort((a, b) {
      final ta = DateTime.tryParse(a['timestamp'] as String? ?? '') ?? DateTime(2000);
      final tb = DateTime.tryParse(b['timestamp'] as String? ?? '') ?? DateTime(2000);
      return tb.compareTo(ta); // newest first
    });

    // Urge Velocity (last 3, newest minus oldest of the 3)
    double urgeVelocity = 0;
    if (allCheckIns.length >= 3) {
      final double newest = (allCheckIns[0]['urge'] as num?)?.toDouble() ?? 0;
      final double oldest = (allCheckIns[2]['urge'] as num?)?.toDouble() ?? 0;
      urgeVelocity = newest - oldest;
    }

    // Peak Hour
    final Map<int, int> highIntensityHours = {};
    int totalHighIntensity = 0;
    for (var c in allCheckIns) {
      final int urge = (c['urge'] as num?)?.toInt() ?? 0;
      if (urge >= 6) {
        final tsStr = c['timestamp'] as String?;
        if (tsStr != null) {
          final ts = DateTime.tryParse(tsStr);
          if (ts != null) {
            highIntensityHours[ts.hour] = (highIntensityHours[ts.hour] ?? 0) + 1;
            totalHighIntensity++;
          }
        }
      }
    }

    int peakHour = 19; // Fallback evening
    int peakHourConfidence = 30; // Fallback confidence
    
    if (totalHighIntensity >= 5) {
      int maxCount = 0;
      highIntensityHours.forEach((hour, count) {
        if (count > maxCount) {
          maxCount = count;
          peakHour = hour;
        }
      });
      peakHourConfidence = ((maxCount / totalHighIntensity) * 100).clamp(0, 100).toInt();
    }

    // Top Trigger
    final Map<String, int> triggerCounts = {};
    for (var c in allCheckIns) {
      final triggersList = c['triggers'];
      if (triggersList is List) {
        for (var t in triggersList) {
          final String ts = t.toString();
          triggerCounts[ts] = (triggerCounts[ts] ?? 0) + 1;
        }
      }
    }

    String topTrigger = coreNeed;
    if (triggerCounts.isNotEmpty) {
      int maxTriggerCount = 0;
      triggerCounts.forEach((trigger, count) {
        if (count > maxTriggerCount) {
          maxTriggerCount = count;
          topTrigger = trigger;
        }
      });
    }

    // Stability Trend
    // avgUrge(days8to14) - avgUrge(days1to7). Positive = improving.
    double sum1to7 = 0;
    int count1to7 = 0;
    double sum8to14 = 0;
    int count8to14 = 0;

    for (var c in allCheckIns) {
      final tsStr = c['timestamp'] as String?;
      if (tsStr != null) {
        final ts = DateTime.tryParse(tsStr);
        if (ts != null) {
          final int daysDiff = now.difference(ts).inDays;
          final double urge = (c['urge'] as num?)?.toDouble() ?? 0;
          if (daysDiff <= 7) {
            sum1to7 += urge;
            count1to7++;
          } else if (daysDiff > 7 && daysDiff <= 14) {
            sum8to14 += urge;
            count8to14++;
          }
        }
      }
    }

    double avg1to7 = count1to7 > 0 ? sum1to7 / count1to7 : 0;
    double avg8to14 = count8to14 > 0 ? sum8to14 / count8to14 : 0;
    double stabilityTrend = 0;
    
    if (count1to7 > 0 && count8to14 > 0) {
      stabilityTrend = avg8to14 - avg1to7; 
    }



    return StiraBehaviourSnapshot(
      userName: userName,
      currentStreak: currentStreak,
      totalCleanDays: totalCleanDays,
      hoursSinceLastCheckIn: hoursSinceLastCheckIn,
      checkedInToday: checkedInToday,
      sentToday: sentToday,
      lastSentAt: lastSentAt,
      restMode: restMode,
      dopamineJournalToday: dopamineJournalToday,
      peakHour: peakHour,
      peakHourConfidence: peakHourConfidence,
      urgeVelocity: urgeVelocity,
      topTrigger: topTrigger,
      stabilityTrend: stabilityTrend,
      coreNeed: coreNeed,
      sameTimeTomorrowDue: sameTimeTomorrowDue,
      commitmentText: commitmentText,
      lastRelapseAt: lastRelapseAt,
      daysSinceInstall: daysSinceInstall,
      personalBestStreak: personalBestStreak,
    );
  }
}
