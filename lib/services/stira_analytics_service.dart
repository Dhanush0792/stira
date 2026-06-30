import "package:firebase_analytics/firebase_analytics.dart";

class StiraAnalyticsService {
  final _analytics = FirebaseAnalytics.instance;

  Future<void> logAppOpen() =>
    _analytics.logAppOpen();

  Future<void> logUrgeCheckedIn({
    required int urgeLevel,
    required List<String> triggers,
  }) => _analytics.logEvent(name: "urge_checked_in", parameters: {
    "urge_level":  urgeLevel,
    "trigger_count": triggers.length,
    "primary_trigger": triggers.isNotEmpty ? triggers.first : "none",
  });

  Future<void> logRelapseEvent({
    required String trigger,
    required int    streakAtRelapse,
    required bool   insuranceUsed,
  }) => _analytics.logEvent(name: "relapse_logged", parameters: {
    "trigger":          trigger,
    "streak_at_relapse": streakAtRelapse,
    "insurance_used":   insuranceUsed,
  });

  Future<void> logStreakMilestone(int days) =>
    _analytics.logEvent(name: "streak_milestone", parameters: {"days": days});

  Future<void> logToolUsed(String toolName) =>
    _analytics.logEvent(name: "tool_used", parameters: {"tool": toolName});

  Future<void> logVaultLetterWritten() =>
    _analytics.logEvent(name: "vault_letter_written");

  Future<void> logVaultLetterRead() =>
    _analytics.logEvent(name: "vault_letter_read");

  Future<void> logDangerZoneEntered(String zoneName) =>
    _analytics.logEvent(name: "danger_zone_entered", parameters: {"zone": zoneName});

  Future<void> logSafeZoneEntered(String zoneName) =>
    _analytics.logEvent(name: "safe_zone_entered", parameters: {"zone": zoneName});

  Future<void> logDopamineJournalEntry(String category) =>
    _analytics.logEvent(name: "dopamine_journal_entry", parameters: {"category": category});

  Future<void> logBondModeConnected() =>
    _analytics.logEvent(name: "bond_mode_connected");


  Future<void> logStreakInsuranceActivated(int streakSaved) =>
    _analytics.logEvent(name: "streak_insurance_activated", parameters: {"streak_saved": streakSaved});

  Future<void> logWeeklyReportViewed() =>
    _analytics.logEvent(name: "weekly_report_viewed");

  Future<void> logOnboardingCompleted(String coreNeed) =>
    _analytics.logEvent(name: "onboarding_completed", parameters: {"core_need": coreNeed});

  Future<void> setUserId(String uid) =>
    _analytics.setUserId(id: uid);

  Future<void> setUserProperty(String name, String value) =>
    _analytics.setUserProperty(name: name, value: value);
}
