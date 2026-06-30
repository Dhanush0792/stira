import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class TelemetryService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> trackUrgeSurfingStarted() async {
    try {
      await _analytics.logEvent(name: 'urge_surfing_started');
    } catch (e) {
      debugPrint('Telemetry err: \$e');
    }
  }

  static Future<void> trackUrgeSurfingCompleted(int initialUrge) async {
    try {
      await _analytics.logEvent(
        name: 'urge_surfing_completed',
        parameters: {'initial_urge': initialUrge},
      );
    } catch (e) {
      debugPrint('Telemetry err: \$e');
    }
  }

  static Future<void> trackUrgeSurfingAborted() async {
    try {
      await _analytics.logEvent(name: 'urge_surfing_aborted');
    } catch (e) {
      debugPrint('Telemetry err: \$e');
    }
  }

  static Future<void> trackCheckInCompleted(int urge, bool isAlone) async {
    try {
      await _analytics.logEvent(
        name: 'checkin_completed',
        parameters: {'urge': urge, 'is_alone': isAlone ? 1 : 0},
      );
    } catch (e) {
      debugPrint('Telemetry err: \$e');
    }
  }

  static Future<void> trackRelapseLogged(String trigger, String emotion) async {
    try {
      await _analytics.logEvent(
        name: 'relapse_logged',
        parameters: {'trigger_type': trigger.isEmpty ? 'unknown' : 'known'},
      );
    } catch (e) {
      debugPrint('Telemetry err: \$e');
    }
  }

  // ── Notification Analytics ──────────────────────────────────────────────────

  static Future<void> trackNotificationReceived(String? id, String? title) async {
    try {
      await _analytics.logEvent(
        name: 'notification_received',
        parameters: {
          'msg_id': id ?? 'none',
          'title': title ?? 'none',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('Telemetry: Notification Received -> \$id');
    } catch (e) {
      debugPrint('Telemetry err: \$e');
    }
  }

  static Future<void> trackNotificationOpened(String? id, String? title) async {
    try {
      await _analytics.logEvent(
        name: 'notification_opened',
        parameters: {
          'msg_id': id ?? 'none',
          'title': title ?? 'none',
        },
      );
      debugPrint('Telemetry: Notification Opened -> \$id');
    } catch (e) {
      debugPrint('Telemetry err: \$e');
    }
  }

  static Future<void> trackTokenSync(bool success, {String? error}) async {
    try {
      await _analytics.logEvent(
        name: 'fcm_token_sync',
        parameters: {
          'success': success ? 1 : 0,
          if (error != null) 'error': error.length > 40 ? error.substring(0, 40) : error,
        },
      );
    } catch (e) {
      debugPrint('Telemetry err: \$e');
    }
  }
}
