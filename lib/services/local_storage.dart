import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/notification_state.dart';
import 'stira_intelligence_engine.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  // ── Schema Version ───────────────────────────────────────────────────────
  //
  // Bump this whenever a stored key's value type changes or a key is removed.
  // migrateIfNeeded() is called once from main.dart on startup.
  static const int currentSchemaVersion = 1;

  /// Called once at startup (before the app widget tree is built).
  /// If the persisted schema version is older than [currentSchemaVersion],
  /// it wipes the logs box (safe — logs are analytics only) and rewrites
  /// the version key.  The prefs box is preserved to avoid losing onboarding
  /// progress, but individual keys that changed type are removed.
  static Future<void> migrateIfNeeded() async {
    final prefs = Hive.box('stira_prefs');
    final stored = prefs.get('schema_version', defaultValue: 0) as int;
    if (stored < currentSchemaVersion) {
      // v0 → v1: logs format changed to include 'mood' key — wipe history.
      final logs = Hive.box('stira_logs');
      await logs.delete('history');
      await prefs.put('schema_version', currentSchemaVersion);
    }

    // Phase 12: Clean up obsolete sleep keys > 60 days
    final now = DateTime.now();
    final keysToRemove = <dynamic>[];
    for (final key in prefs.keys) {
      if (key is String && key.startsWith('sleep_')) {
        final dateStr = key.substring(6);
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          if (now.difference(dt).inDays > 60) {
            keysToRemove.add(key);
          }
        }
      }
    }
    if (keysToRemove.isNotEmpty) {
      await prefs.deleteAll(keysToRemove);
    }
  }

  // Phase 14: Unified Intelligence Boxes
  final _userData = Hive.box('user_data');
  final _checkIns = Hive.box('check_ins');
  final _prefs = Hive.box('stira_prefs'); // For UI settings only

  // ── Preferences ───────────────────────────────────────────────────────────
  bool isLowPerformanceMode() {
    return _prefs.get('low_perf_mode', defaultValue: false);
  }

  Future<void> setLowPerformanceMode(bool value) async {
    await _prefs.put('low_perf_mode', value);
  }

  // ── Onboarding ────────────────────────────────────────────────────────────

  bool get onboardingCompleted =>
      _prefs.get('onboarding_completed', defaultValue: false) as bool;

  Future<void> setOnboardingCompleted() async {
    await _prefs.put('onboarding_completed', true);
  }

  // ── Intro Walkthrough ──────────────────────────────────────────────────────

  bool get hasSeenIntro =>
      _prefs.get('has_seen_intro', defaultValue: false) as bool;

  Future<void> setHasSeenIntro() async {
    await _prefs.put('has_seen_intro', true);
  }

  /// Resets the intro flag — used when a new session starts with no signed-in user.
  Future<void> resetIntroSeen() async {
    await _prefs.put('has_seen_intro', false);
  }

  // ── Guest Mode ────────────────────────────────────────────────────────────

  /// True when the user opted to use the app without signing in.
  /// Guest users have full local functionality but no cloud sync or Bond Mode.
  bool get isGuestMode =>
      _prefs.get('guest_mode', defaultValue: false) as bool;

  Future<void> setGuestMode(bool value) async {
    await _prefs.put('guest_mode', value);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<void> saveProfile(Map<String, dynamic> data) async {
    await _prefs.put('profile', data);
  }

  Map<String, dynamic>? getProfile() {
    final data = _prefs.get('profile');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // ── Monetization & Premium ────────────────────────────────────────────────

  /// Returns true if the user has an active premium subscription.
  /// This reads from Hive storage — set via setPremium() after purchase verification.
  bool get isPremium => _prefs.get('is_premium', defaultValue: false) as bool;


  Future<void> setPremium(bool val) async {
    await _prefs.put('is_premium', val);
  }

  DateTime? get lastWeeklyReport {
    final s = _prefs.get('last_weekly_report') as String?;
    return s != null ? DateTime.parse(s) : null;
  }

  Future<void> setLastWeeklyReport(DateTime dt) async {
    await _prefs.put('last_weekly_report', dt.toIso8601String());
  }

  // ── Check-in Logs ─────────────────────────────────────────────────────────

  Future<void> addLog(Map<String, dynamic> log) async {
    await _checkIns.add(log);
  }

  List<Map<String, dynamic>> getLogs() {
    return _checkIns.values
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  List<Map<String, dynamic>> getCheckinHistory() {
    return getLogs();
  }

  // ── Relapse Logs ──────────────────────────────────────────────────────────

  /// Stores rich relapse timestamps for forecast analysis.
  // ── Relapse Logs ──────────────────────────────────────────────────────────

  /// Stores rich relapse timestamps for forecast analysis.
  Future<void> addRelapseLog(DateTime dt) async {
    final list = List<dynamic>.from(_userData.get('relapses', defaultValue: []));
    list.add(dt.toIso8601String());
    await _userData.put('relapses', list);
  }

  List<DateTime> getRelapseLogs() {
    final list = _userData.get('relapses', defaultValue: []);
    return List<dynamic>.from(list)
        .map((e) => DateTime.parse(e as String))
        .toList();
  }

  // ── Relapse Logs & Triggers ───────────────────────────────────────────────
  /// Stores the triggers collected during the Compassionate Autopsy (Reset flow)
  Future<void> addRelapseTrigger(Map<String, dynamic> log) async {
    final list = List<dynamic>.from(_userData.get('relapse_triggers', defaultValue: []));
    list.add(log);
    await _userData.put('relapse_triggers', list);
  }

  List<Map<String, dynamic>> getRelapseTriggers() {
    final list = _userData.get('relapse_triggers', defaultValue: []);
    return List<dynamic>.from(list)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ── The Vault ─────────────────────────────────────────────────────────────

  /// Deposits a new memory fragment into the Vault.
  Future<void> addVaultFragment(String fragment) async {
    final list = List<dynamic>.from(_prefs.get('vault_fragments', defaultValue: []));
    list.add(fragment);
    await _prefs.put('vault_fragments', list);
  }

  /// Retrieves all unlocked memory fragments.
  List<String> getVaultFragments() {
    final list = _prefs.get('vault_fragments', defaultValue: []);
    return List<dynamic>.from(list).map((e) => e as String).toList();
  }

  // ── Biometrics (Security) ──────────────────────────────────────────────────

  bool get isBiometricEnabled => _prefs.get('biometric_enabled', defaultValue: false);

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.put('biometric_enabled', enabled);
    debugPrint('Biometric setting saved: $enabled');
  }

  // ── Biometrics (Sleep) ────────────────────────────────────────────────────

  /// Logs sleep hours for today
  Future<void> logSleep(int hours) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    await _prefs.put('sleep_$dateStr', hours);
  }

  /// Gets today's sleep hours. Returns null if not logged yet.
  int? getTodaySleep() {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    final val = _prefs.get('sleep_$dateStr');
    return val as int?;
  }

  /// Returns a map of all stored sleep history, keyed by YYYY-M-D.
  Map<String, int> getSleepHistory() {
    final Map<String, int> history = {};
    for (final key in _prefs.keys) {
      if (key is String && key.startsWith('sleep_')) {
        final dateStr = key.substring(6);
        final val = _prefs.get(key);
        if (val is int) {
          history[dateStr] = val;
        }
      }
    }
    return history;
  }

  // ── Geofencing (Danger Zones) ─────────────────────────────────────────────

  Future<void> addDangerZone(Map<String, dynamic> zone) async {
    final list = List<dynamic>.from(_prefs.get('danger_zones', defaultValue: []));
    list.add(zone);
    await _prefs.put('danger_zones', list);
  }

  Future<void> removeDangerZone(int index) async {
    final list = List<dynamic>.from(_prefs.get('danger_zones', defaultValue: []));
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await _prefs.put('danger_zones', list);
    }
  }

  List<Map<String, dynamic>> getDangerZones() {
    final list = _prefs.get('danger_zones', defaultValue: []);
    return List<dynamic>.from(list).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Dates ─────────────────────────────────────────────────────────────────

  DateTime? get firstCheckInDate {
    final v = _prefs.get('first_checkin_date');
    return v != null ? DateTime.parse(v as String) : null;
  }

  Future<void> setFirstCheckInDate(DateTime date) async {
    await _prefs.put('first_checkin_date', date.toIso8601String());
  }

  DateTime? get lastRelapseDate {
    final s = _prefs.get('last_relapse_date') as String?;
    return s != null ? DateTime.parse(s) : null;
  }

  Future<void> setLastRelapseDate(DateTime date) async {
    await _prefs.put('last_relapse_date', date.toIso8601String());
    // Also append to relapse log for frequency analysis
    await addRelapseLog(date);
    // Notification Intelligence engine trigger
    await Hive.box('check_ins').add({'type': 'relapse', 'timestamp': date.toIso8601String()});
    await StiraIntelligenceEngine.reactToAction(UserAction.relapseLogged);
  }

  // ── Ghost Mode ────────────────────────────────────────────────────────────

  /// Expiry time for Ghost Mode (Anti-Relapse Binge Protocol).
  DateTime? get ghostModeExpiry {
    final s = _prefs.get('ghost_mode_expiry') as String?;
    return s != null ? DateTime.parse(s) : null;
  }

  /// Activates Ghost Mode for 24 hours.
  Future<void> activateGhostMode() async {
    final expiry = DateTime.now().add(const Duration(hours: 24));
    await _prefs.put('ghost_mode_expiry', expiry.toIso8601String());
  }

  /// Deactivates Ghost Mode immediately.
  Future<void> deactivateGhostMode() async {
    await _prefs.delete('ghost_mode_expiry');
  }

  /// Checks if Ghost Mode is currently active.
  bool get isGhostModeActive {
    final expiry = ghostModeExpiry;
    if (expiry == null) return false;
    if (DateTime.now().isAfter(expiry)) {
      _prefs.delete('ghost_mode_expiry');
      return false;
    }
    return true;
  }

  // ── Streak ────────────────────────────────────────────────────────────────

  DateTime? get streakStartTime {
    final relapse = lastRelapseDate;
    if (relapse != null) return relapse;
    return firstCheckInDate;
  }

  int calculateStreak() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final relapse = lastRelapseDate;
    if (relapse != null) {
      final relapseDate = DateTime(relapse.year, relapse.month, relapse.day);
      return todayDate.difference(relapseDate).inDays;
    }

    final first = firstCheckInDate;
    if (first != null) {
      final firstDate = DateTime(first.year, first.month, first.day);
      return todayDate.difference(firstDate).inDays + 1;
    }

    return 0;
  }

  int get longestStreak {
    final cur = calculateStreak();
    final stored = _prefs.get('longest_streak', defaultValue: 0) as int;
    if (cur > stored) {
      _prefs.put('longest_streak', cur);
      return cur;
    }
    return stored;
  }

  int getDaysSteady() => calculateStreak();

  Future<void> updateDaysSteady(int days) async {
    await _prefs.put('days_steady', days);
  }

  // ── Stability Metrics ─────────────────────────────────────────────────────

  int get elevatedRiskCount =>
      _prefs.get('elevated_risk_count', defaultValue: 0) as int;

  Future<void> incrementElevatedRiskCount() async {
    await _prefs.put('elevated_risk_count', elevatedRiskCount + 1);
  }

  double get storedStabilityIndex {
    return (_prefs.get('stored_stability_index', defaultValue: 0.0) as num).toDouble();
  }

  Future<void> setStoredStabilityIndex(double value) async {
    await _prefs.put('stored_stability_index', value);
  }

  // ── Future You Message ────────────────────────────────────────────────────

  String? get futureYouMessage {
    final v = _prefs.get('future_you_message');
    return v != null ? v as String : null;
  }

  Future<void> setFutureYouMessage(String message) async {
    await _prefs.put('future_you_message', message);
  }

  // ── Notification Preferences ──────────────────────────────────────────────

  bool get notificationsEnabled =>
      _prefs.get('notifications_enabled', defaultValue: false) as bool;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.put('notifications_enabled', enabled);
  }

  bool get notificationPermissionAsked =>
      _prefs.get('notification_permission_asked', defaultValue: false) as bool;

  Future<void> setNotificationPermissionAsked() async {
    await _prefs.put('notification_permission_asked', true);
  }

  // ── Notification Throttle ─────────────────────────────────────────────────

  int get notificationSentToday {
    final v = _prefs.get('notif_sent_today');
    if (v == null) return 0;
    return v as int;
  }

  Future<void> setNotificationSentToday(int val) async {
    await _prefs.put('notif_sent_today', val);
  }

  DateTime? get lastNotificationSent {
    final s = _prefs.get('notif_last_sent') as String?;
    return s != null ? DateTime.parse(s) : null;
  }

  Future<void> setLastNotificationSent(DateTime dt) async {
    await _prefs.put('notif_last_sent', dt.toIso8601String());
  }

  DateTime? get lastIsolationPrompt {
    final s = _prefs.get('notif_last_isolation') as String?;
    return s != null ? DateTime.parse(s) : null;
  }

  Future<void> setLastIsolationPrompt(DateTime dt) async {
    await _prefs.put('notif_last_isolation', dt.toIso8601String());
  }

  DateTime? get lastStabilityUpdate {
    final s = _prefs.get('notif_last_stability') as String?;
    return s != null ? DateTime.parse(s) : null;
  }

  Future<void> setLastStabilityUpdate(DateTime dt) async {
    await _prefs.put('notif_last_stability', dt.toIso8601String());
  }

  // ── Dopamine Journal ──────────────────────────────────────────────────────

  Future<void> addDopamineEntry(Map<String, dynamic> entry) async {
    final box = Hive.box('dopamine_journal');
    await box.add(entry);
  }

  List<Map<String, dynamic>> getDopamineEntries() {
    final box = Hive.box('dopamine_journal');
    return box.values
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ── Affirmations ───────────────────────────────────────────────────────────

  int get affirmationIndex => _prefs.get('affirmation_index', defaultValue: 0) as int;

  Future<void> setAffirmationIndex(int index) async {
    await _prefs.put('affirmation_index', index);
  }

  int get affirmationRefreshCount => _prefs.get('affirmation_refresh_count', defaultValue: 0) as int;

  Future<void> setAffirmationRefreshCount(int count) async {
    await _prefs.put('affirmation_refresh_count', count);
  }

  DateTime? get lastAffirmationRefreshDate {
    final s = _prefs.get('last_affirmation_refresh_date') as String?;
    return s != null ? DateTime.parse(s) : null;
  }

  Future<void> setLastAffirmationRefreshDate(DateTime dt) async {
    await _prefs.put('last_affirmation_refresh_date', dt.toIso8601String());
  }

  // ── Shadow Mode ─────────────────────────────────────────────────────────────

  String get activeDisguise => _prefs.get('active_disguise', defaultValue: 'None') as String;

  Future<void> setActiveDisguise(String disguise) async {
    await _prefs.put('active_disguise', disguise);
  }

  // ── Notification Intelligence State ──────────────────────────────────────

  NotificationState getNotificationState() {
    final jsonStr = _prefs.get('notification_state_json');
    if (jsonStr == null) return NotificationState.initial();
    try {
      return NotificationState.fromJson(jsonDecode(jsonStr as String));
    } catch (e) {
      return NotificationState.initial();
    }
  }

  Future<void> saveNotificationState(NotificationState state) async {
    await _prefs.put('notification_state_json', jsonEncode(state.toJson()));
  }

  // ── Adaptive Scheduler Helpers (Phase 1 Refactor) ──────────────────────────

  Future<void> recordNotificationSent(DateTime now) async {
    final state = getNotificationState();
    state.markSent();
    await saveNotificationState(state);
  }

  Future<void> recordLastAction() async {
    final state = getNotificationState();
    state.lastActionAt = DateTime.now();
    await saveNotificationState(state);
  }

  DateTime? getLastNotificationTime() => getNotificationState().lastSentAt;

  int getTodayNotificationCount() {
    final state = getNotificationState();
    state.checkReset();
    return state.sentToday;
  }

  bool isWeeklyReportScheduled(DateTime now) {
    final last = _prefs.get('weekly_report_scheduled_date') as String?;
    if (last == null) return false;
    final lastDt = DateTime.parse(last);
    return now.difference(lastDt).inDays < 7 && now.weekday == lastDt.weekday;
  }

  Future<void> markWeeklyReportScheduled(DateTime now) async {
    await _prefs.put('weekly_report_scheduled_date', now.toIso8601String());
  }

  // ── FCM Token & History ───────────────────────────────────────────────────

  String? get fcmToken => _prefs.get('fcm_token') as String?;

  Future<void> setFcmToken(String? token) async {
    if (token == null) {
      await _prefs.delete('fcm_token');
    } else {
      await _prefs.put('fcm_token', token);
    }
  }

  DateTime? get fcmTokenLastUpdated {
    final s = _prefs.get('fcm_token_last_updated') as String?;
    return s != null ? DateTime.parse(s) : null;
  }

  Future<void> setFcmTokenLastUpdated(DateTime dt) async {
    await _prefs.put('fcm_token_last_updated', dt.toIso8601String());
  }

  Future<void> addNotificationToHistory(Map<String, dynamic> notification) async {
    final list = List<dynamic>.from(_userData.get('notification_history', defaultValue: []));
    list.insert(0, notification);
    // Keep last 50 for performance
    if (list.length > 50) list.removeLast();
    await _userData.put('notification_history', list);
  }

  List<Map<String, dynamic>> getNotificationHistory() {
    final list = _userData.get('notification_history', defaultValue: []);
    return List<dynamic>.from(list)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  /// Wipes all data and resets schema version.
  /// Used for Delete Account.
  Future<void> clearAll() async {
    await _prefs.clear();
    await _checkIns.clear();
    // Also wipe all other Hive boxes that store sensitive health data.
    // This ensures full GDPR erasure when the account is deleted.
    try {
      await _userData.clear();
    } catch (_) {}
    try {
      final dopamineBox = Hive.box('dopamine_journal');
      await dopamineBox.clear();
    } catch (_) {}
    await _prefs.put('schema_version', currentSchemaVersion);
  }

  /// Alias for clearAll — used by guest users from the legal/support screen.
  Future<void> clearAllLocalData() => clearAll();

}
