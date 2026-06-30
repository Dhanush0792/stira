import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage.dart';
import '../services/cloud_sync_service.dart';
import 'risk_engine.dart';
import 'behavior_engine.dart';
import 'escalation_engine.dart';
import '../services/adaptive_scheduler.dart';

enum BehaviorMode {
  neutralSupport,
  attentiveRegulation,
  protectiveContainment,
}

enum SuggestedAction {
  takeBreath,
  physicalReset,
  contactShift,
  restGuidance,
  groundingFirst
}

enum NotificationPlan {
  adaptiveTimingActive,
  criticalOnly,
  suppressed,
  weeklyReportOnly
}

class StabilityState {
  final RiskLevel riskLevel;
  final BehaviorMode behaviorMode;
  final int stabilityIndex;
  final ForecastWindow? forecastWindow;
  final double forecastConfidence;
  final List<String> primaryDrivers;
  final SuggestedAction suggestedAction;
  final int escalationLevel;
  final NotificationPlan notificationPlan;

  // Analytics & UI Cache
  final bool isGhostMode;
  final int streak;
  final int longestStreak;
  final List<int> streakHistory;
  final String? futureYouMessage;
  final bool hasLoggedSleepToday;
  final int totalCheckins;
  final bool hasEnoughData;
  final Set<String> checkinDates;
  final Map<String, int> topTriggers;
  final Map<String, int> topLocations;
  final Map<String, int> dailyUrgeMap;
  final Map<int, int> hourlyVulnerability;
  final List<int> topVulnerabilityHours;
  final int stabilityDelta;
  final bool hasRisingVelocity;
  final bool hasPrecisePatternMatch;
  final int motivationRotationIndex;

  const StabilityState({
    required this.riskLevel,
    required this.behaviorMode,
    required this.stabilityIndex,
    required this.forecastWindow,
    required this.forecastConfidence,
    required this.primaryDrivers,
    required this.suggestedAction,
    required this.escalationLevel,
    required this.notificationPlan,
    required this.isGhostMode,
    required this.streak,
    required this.longestStreak,
    required this.streakHistory,
    required this.futureYouMessage,
    required this.hasLoggedSleepToday,
    required this.totalCheckins,
    required this.hasEnoughData,
    required this.checkinDates,
    required this.topTriggers,
    required this.topLocations,
    required this.dailyUrgeMap,
    required this.hourlyVulnerability,
    required this.topVulnerabilityHours,
    required this.stabilityDelta,
    this.hasRisingVelocity = false,
    this.hasPrecisePatternMatch = false,
    this.motivationRotationIndex = 0,
  });

  factory StabilityState.initial() {
    return const StabilityState(
      riskLevel: RiskLevel.low,
      behaviorMode: BehaviorMode.neutralSupport,
      stabilityIndex: 0,
      forecastWindow: null,
      forecastConfidence: 0.0,
      primaryDrivers: [],
      suggestedAction: SuggestedAction.takeBreath,
      escalationLevel: 0,
      notificationPlan: NotificationPlan.adaptiveTimingActive,
      isGhostMode: false,
      streak: 0,
      longestStreak: 0,
      streakHistory: [],
      futureYouMessage: null,
      hasLoggedSleepToday: false,
      totalCheckins: 0,
      hasEnoughData: false,
      checkinDates: {},
      topTriggers: {},
      topLocations: {},
      dailyUrgeMap: {},
      hourlyVulnerability: {},
      topVulnerabilityHours: [],
      stabilityDelta: 0,
    );
  }
}

final intelligenceProvider =
    StateNotifierProvider<IntelligenceLayer, StabilityState>((ref) {
  final sync = ref.watch(cloudSyncProvider);
  return IntelligenceLayer(StorageService(), sync);
});

class IntelligenceLayer extends StateNotifier<StabilityState> {
  final StorageService _storage;
  final CloudSyncService _sync;

  IntelligenceLayer(this._storage, this._sync) : super(StabilityState.initial()) {
    recompute();
  }

  Future<void> recompute() async {
    await _recomputeAsync();
    // Fire-and-forget background sync to cloud is okay to stay unawaited here 
    // but the main recompute should be awaited.
    unawaited(_sync.syncHistoryToCloud());
  }

  Future<void> _recomputeAsync() async {
    final logs = _storage.getLogs();
    final relapses = _storage.getRelapseLogs();
    final isGhostMode = _storage.isGhostModeActive;
    
    // UI Caches
    final streak = _storage.calculateStreak();
    final longestStreak = _storage.longestStreak;
    final firstDate = _storage.firstCheckInDate ?? (relapses.isNotEmpty ? relapses.first.subtract(const Duration(days: 1)) : DateTime.now());
    
    final sortedRelapses = relapses.toList()..sort();
    final List<int> streakHistory = [];
    DateTime lastR = firstDate;
    for (final r in sortedRelapses) {
      if (r.isBefore(firstDate)) continue; 
      streakHistory.add(r.difference(lastR).inDays);
      lastR = r;
    }
    streakHistory.add(DateTime.now().difference(lastR).inDays);

    final futureYouMessage = _storage.futureYouMessage;
    final sleepToday = _storage.getTodaySleep();
    final hasLoggedSleepToday = sleepToday != null;
    final hasEnoughData = logs.length >= 3 || relapses.isNotEmpty;
    final totalCheckins = logs.length;
    
    final checkinDates = <String>{};
    final dailyUrgeMap = <String, int>{};
    final hourlyVulnerability = <int, int>{};

    for (final log in logs) {
      final tsStr = log['timestamp'] as String?;
      if (tsStr == null) continue;
      final dt = DateTime.tryParse(tsStr);
      if (dt == null) continue;
      final ds = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      checkinDates.add(ds);

      final urgeLevel = log['urge_level'] as int? ?? 0;
      if (!dailyUrgeMap.containsKey(ds) || urgeLevel > dailyUrgeMap[ds]!) {
        dailyUrgeMap[ds] = urgeLevel;
      }

      if (urgeLevel >= 7) {
        hourlyVulnerability[dt.hour] = (hourlyVulnerability[dt.hour] ?? 0) + 1;
      }
    }

    // Top 2 high-risk hours (pattern mining)
    final topVulnerabilityHours = hourlyVulnerability.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final cleanTopVulnerabilityHours = topVulnerabilityHours
        .where((e) => e.value >= 2) // At least twice at this hour
        .take(2)
        .map((e) => e.key)
        .toList();

    final triggers = _storage.getRelapseTriggers();
    final topTriggers = <String, int>{};
    final topLocations = <String, int>{};
    for (final t in triggers) {
      if (t['emotion'] != null) {
        topTriggers[t['emotion'] as String] = (topTriggers[t['emotion']] ?? 0) + 1;
      }
      if (t['location'] != null) {
        topLocations[t['location'] as String] = (topLocations[t['location']] ?? 0) + 1;
      }
    }
    
    final sortedT = topTriggers.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    final cleanTopTriggers = Map.fromEntries(sortedT.take(3));
    
    final sortedL = topLocations.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    final cleanTopLocations = Map.fromEntries(sortedL.take(3));

    final now = DateTime.now();
    final logsLast7 = logs.where((l) {
      final dt = DateTime.tryParse(l['timestamp'].toString());
      if (dt == null) return false;
      return now.difference(dt).inDays <= 7;
    }).length;

    // Behavior Engine (14-day rolling window)
    final sleepHistory = _storage.getSleepHistory();
    final profile = await BehaviorEngine.analyzeAsync(logs, sleepHistory, relapses);

    // Risk Engine
    final recentLogs = logs.where((l) {
      final dt = DateTime.tryParse(l['timestamp'].toString());
      if (dt == null) return false;
      return now.difference(dt).inHours <= 24;
    }).toList();
    
    final elevatedEvents = recentLogs.where((l) => (l['urge_level'] as int? ?? 0) >= 7).length;
    final relapseWithin72h = relapses.any((r) => now.difference(r).inHours <= 72);
    
    final latestLog = logs.isNotEmpty ? logs.last : null;
    final currentUrgeLevel = latestLog != null ? (latestLog['urge_level'] as int? ?? 5) : 5;
    final currentlyAlone = latestLog != null ? (latestLog['alone'] == true) : false;
    
    // Check if in high risk window
    bool inHighRiskWindow = false;
    if (profile.forecastWindow != null) {
      final startH = profile.forecastWindow!.startTime.hour;
      final endH = profile.forecastWindow!.endTime.hour;
      final curH = now.hour;
      if (startH <= endH) {
        inHighRiskWindow = curH >= startH && curH < endH;
      } else {
        inHighRiskWindow = curH >= startH || curH < endH; 
      }
    }

    final riskResult = RiskEngine.evaluate(
      urgeLevel: currentUrgeLevel,
      alone: currentlyAlone,
      energyLevel: 5, // Default for now
      sleepHours: sleepToday ?? -1,
      currentTime: now,
      highRiskWindowMatch: inHighRiskWindow,
      isolationAmplifier: profile.isolationAmplifier,
      relapseWithin72h: relapseWithin72h,
      elevatedEventsLast24h: elevatedEvents,
    );

    // Identify Drivers
    final drivers = <String>[];
    if (profile.dominantTrigger != null) drivers.add(profile.dominantTrigger!);
    if (profile.isolationAmplifier) drivers.add('Isolation');
    if (profile.fatigueInfluence) drivers.add('Fatigue');
    if (profile.volatilityLevel == VolatilityLevel.high) drivers.add('Volatility');

    // Intervention Selector
    SuggestedAction recommendedAction = SuggestedAction.takeBreath;
    if (drivers.contains('Bored') || drivers.contains('Boredom')) {
      recommendedAction = SuggestedAction.physicalReset;
    } else if (drivers.contains('Lonely') || drivers.contains('Isolation')) {
      recommendedAction = SuggestedAction.contactShift;
    } else if (drivers.contains('Tired') || drivers.contains('Fatigue')) {
      recommendedAction = SuggestedAction.restGuidance;
    } else if (drivers.contains('Volatility')) {
      recommendedAction = SuggestedAction.groundingFirst;
    }

    // Escalation Ladder using EscalationEngine
    final escalationLevel = EscalationEngine.evaluate(
      riskScore: riskResult.riskScore,
      alone: currentlyAlone,
      nearForecastWindow: inHighRiskWindow,
      relapseWithin72h: relapseWithin72h,
      elevatedEventsLast24h: elevatedEvents,
      isolationAmplifier: profile.isolationAmplifier,
    );

    // Behavior Mode Calculation (Overrides by Escalation)
    BehaviorMode mode = BehaviorMode.neutralSupport;
    if (isGhostMode || escalationLevel == 4) {
      mode = BehaviorMode.protectiveContainment;
    } else if (escalationLevel == 3 || escalationLevel == 2) {
      mode = BehaviorMode.attentiveRegulation;
    } else if (escalationLevel == 1) {
      mode = BehaviorMode.attentiveRegulation;
    }
    
    // Notification Plan
    NotificationPlan plan = NotificationPlan.adaptiveTimingActive;
    if (escalationLevel >= 3) {
      plan = NotificationPlan.criticalOnly;
    } else if (isGhostMode) {
      plan = NotificationPlan.suppressed;
    }

    // Stability Index Rewrite
    double calcIndex = _calculateRawStability(profile, logsLast7, elevatedEvents);
    double oldIndex = _storage.storedStabilityIndex;
    
    double newIndex = (oldIndex * 0.75) + (calcIndex * 0.25);
    final delta = newIndex - oldIndex;
    if (delta > 8) newIndex = oldIndex + 8;
    if (delta < -8) newIndex = oldIndex - 8;
    newIndex = newIndex.clamp(0.0, 100.0);
    _storage.setStoredStabilityIndex(newIndex);

    // Phase 2 Signals
    final notifState = _storage.getNotificationState();
    
    // N-04 Rising Velocity: Last 3 urges strictly increasing (e.g. 2 -> 4 -> 7)
    final recentUrges = logs.length >= 3 
      ? logs.sublist(logs.length - 3).map((l) => l['urge_level'] as int? ?? 0).toList()
      : <int>[];
    bool hasRisingVelocity = false;
    if (recentUrges.length == 3) {
      hasRisingVelocity = recentUrges[0] < recentUrges[1] && recentUrges[1] < recentUrges[2];
      // Store in notifState for persistence if needed
      notifState.last3Urges = recentUrges;
      await _storage.saveNotificationState(notifState);
    }

    // N-06 Precise Pattern Match: Current hour has been risk-elevated in 80% of data samples
    // For Phase 1 simplification: if it's in topVulnerabilityHours AND today is a peak weekday
    bool hasPrecisePatternMatch = cleanTopVulnerabilityHours.contains(now.hour);

    // Phase 3: Sync to NotificationState
    notifState.behaviorMode = mode == BehaviorMode.neutralSupport ? 'neutralSupport' 
        : (mode == BehaviorMode.attentiveRegulation ? 'attentiveRegulation' : 'protectiveContainment');
    notifState.escalationLevel = escalationLevel;
    notifState.isGhostMode = isGhostMode;
    notifState.crisisActive = riskResult.riskLevel == RiskLevel.elevated || riskResult.riskLevel == RiskLevel.critical;
    await _storage.saveNotificationState(notifState);

    state = StabilityState(
      riskLevel: riskResult.riskLevel,
      behaviorMode: mode,
      stabilityIndex: newIndex.toInt(),
      forecastWindow: profile.forecastWindow,
      forecastConfidence: profile.forecastConfidence,
      primaryDrivers: drivers,
      suggestedAction: recommendedAction,
      escalationLevel: escalationLevel,
      notificationPlan: plan,
      isGhostMode: isGhostMode,
      streak: streak,
      longestStreak: longestStreak,
      streakHistory: streakHistory,
      futureYouMessage: futureYouMessage,
      hasLoggedSleepToday: hasLoggedSleepToday,
      totalCheckins: totalCheckins,
      hasEnoughData: hasEnoughData,
      checkinDates: checkinDates,
      topTriggers: cleanTopTriggers,
      topLocations: cleanTopLocations,
      dailyUrgeMap: dailyUrgeMap,
      hourlyVulnerability: hourlyVulnerability,
      topVulnerabilityHours: cleanTopVulnerabilityHours,
      stabilityDelta: delta.toInt(),
      hasRisingVelocity: hasRisingVelocity,
      hasPrecisePatternMatch: hasPrecisePatternMatch,
      motivationRotationIndex: notifState.motivationIndex,
    );
    
    // Sync Notification Schedule
    AdaptiveScheduler.syncSchedule(state);
  }

  double _calculateRawStability(BehaviorProfile profile, int logsLast7, int elevatedLast24h) {
    // 0 to 100.
    double recovery = 0;
    if (profile.recoveryTrend == Trend.improving) recovery = 1.0;
    if (profile.recoveryTrend == Trend.stable) recovery = 0.5;
    
    double frequency = 1.0;
    // We use a proxy: elevated last 24h as frequency? Or elevated logs last 7 days?
    // For simplicity:
    if (elevatedLast24h >= 2) {
      frequency = 0.0;
    } else if (elevatedLast24h == 1) {
      frequency = 0.5;
    }

    double volatility = 0;
    if (profile.volatilityLevel == VolatilityLevel.low) {
      volatility = 1.0;
    } else if (profile.volatilityLevel == VolatilityLevel.moderate) {
      volatility = 0.5;
    }

    double consistency = logsLast7 >= 5 ? 1.0 : (logsLast7 / 5.0).clamp(0.0, 1.0);
    
    double intervention = 1.0; // Assume compliance unless tracked closely
    
    double isolationDelta = profile.isolationAmplifier ? 0.0 : 1.0;

    double score = 
      (recovery * 25) +
      (frequency * 20) +
      (volatility * 20) +
      (consistency * 15) +
      (intervention * 10) +
      (isolationDelta * 10);
      
    return score;
  }

  /// Evaluates an in-progress Check-In strictly for immediate UI feedback.
  Future<RiskResult> evaluateCheckInAsync({required int urgeLevel, required bool isAlone}) async {
    final now = DateTime.now();
    final relapses = _storage.getRelapseLogs();
    final relapseWithin72h = relapses.any((r) => now.difference(r).inHours <= 72);
    
    final logs = _storage.getLogs();
    final recentLogs = logs.where((l) {
      final dt = DateTime.tryParse(l['timestamp'].toString());
      if (dt == null) return false;
      return now.difference(dt).inHours <= 24;
    }).toList();
    final elevatedEvents = recentLogs.where((l) => (l['urge_level'] as int? ?? 0) >= 7).length;

    final profile = await BehaviorEngine.analyzeAsync(logs, _storage.getSleepHistory(), relapses);

    bool inHighRiskWindow = false;
    if (profile.forecastWindow != null) {
      final startH = profile.forecastWindow!.startTime.hour;
      final endH = profile.forecastWindow!.endTime.hour;
      final curH = now.hour;
      if (startH <= endH) {
        inHighRiskWindow = curH >= startH && curH < endH;
      } else {
        inHighRiskWindow = curH >= startH || curH < endH; 
      }
    }

    return RiskEngine.evaluate(
      urgeLevel: urgeLevel,
      alone: isAlone,
      energyLevel: 5,
      sleepHours: _storage.getTodaySleep() ?? -1,
      currentTime: now,
      highRiskWindowMatch: inHighRiskWindow,
      isolationAmplifier: profile.isolationAmplifier,
      relapseWithin72h: relapseWithin72h,
      elevatedEventsLast24h: elevatedEvents,
    );
  }
}
