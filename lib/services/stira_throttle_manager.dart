import 'package:hive_flutter/hive_flutter.dart';

class StiraThrottleManager {
  static bool canSend({bool isCrisis = false}) {
    final prefs = Hive.box('stira_prefs');
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Midnight Reset
    final String? lastReset = prefs.get('last_reset_date');
    if (lastReset != todayStr) {
      prefs.put('sentToday', 0);
      prefs.put('last_reset_date', todayStr);
    }

    final bool crisisActive = prefs.get('crisis_active', defaultValue: false) == true || isCrisis;

    // Quiet Hours Rule
    if (!crisisActive) {
      if (now.hour >= 22 || now.hour < 8) {
        return false;
      }
    }

    // Rest Mode Check
    bool restMode = false;
    final String? restModeUntilStr = prefs.get('rest_mode_until');
    if (restModeUntilStr != null) {
      final restModeUntil = DateTime.tryParse(restModeUntilStr);
      if (restModeUntil != null) {
        if (restModeUntil.isAfter(now)) {
          restMode = true;
        } else {
          prefs.delete('rest_mode_until');
          restMode = false;
        }
      }
    }

    // Daily Limit Rule
    final int sentToday = prefs.get('sentToday', defaultValue: 0);
    int limit = restMode ? 1 : 2;
    if (crisisActive) limit = 4;
    
    if (sentToday >= limit) {
      return false;
    }

    // Minimum Gap Rule
    if (!crisisActive) {
      final String? lastSentStr = prefs.get('lastSentAt');
      if (lastSentStr != null) {
        final lastSentAt = DateTime.tryParse(lastSentStr);
        if (lastSentAt != null) {
          if (now.difference(lastSentAt).inHours < 3) {
            return false;
          }
        }
      }
    }

    return true;
  }

  static void recordSent() {
    final prefs = Hive.box('stira_prefs');
    final int sentToday = prefs.get('sentToday', defaultValue: 0);
    prefs.put('sentToday', sentToday + 1);
    prefs.put('lastSentAt', DateTime.now().toIso8601String());
  }

  static void recordTap() {
    final prefs = Hive.box('stira_prefs');
    prefs.put('consecutive_untapped', 0);
    prefs.delete('rest_mode_until');
  }

  static void recordUntapped() {
    final prefs = Hive.box('stira_prefs');
    final int untapped = prefs.get('consecutive_untapped', defaultValue: 0) + 1;
    prefs.put('consecutive_untapped', untapped);
    
    if (untapped >= 5) {
      final restUntil = DateTime.now().add(const Duration(days: 7));
      prefs.put('rest_mode_until', restUntil.toIso8601String());
    }
  }

  static void setCrisisActive(bool active) {
    final prefs = Hive.box('stira_prefs');
    prefs.put('crisis_active', active);
  }
}
