import 'models/notification_state.dart';
import 'package:flutter/foundation.dart';

class EligibilityEngine {
  /// Evaluates whether a notification is currently eligible to be sent.
  static EligibilityResult evaluate({
    required NotificationState state,
    required DateTime now,
    bool isUrgentOrSOS = false,
  }) {
    // 1. Ghost Mode (Binge suppression)
    if (state.isGhostMode && !isUrgentOrSOS) {
      return EligibilityResult.blocked('Ghost Mode active');
    }

    // 2. Rest Mode (extended user-configured silence)
    if (state.restMode && !isUrgentOrSOS) {
      return EligibilityResult.blocked('Rest Mode active');
    }

    if (!isUrgentOrSOS) {
      // 3. Quiet Hours (22:30 – 08:00)
      if (_isInQuietHours(state, now)) {
        return EligibilityResult.blocked('Quiet Hours active');
      }

      // 4. Daily Limit (adaptive: 2 normal, 4 in crisis)
      final limit = (state.escalationLevel >= 3 || state.crisisActive) ? 4 : 2;
      if (state.sentToday >= limit) {
        return EligibilityResult.blocked('Daily limit ($limit) reached');
      }

      // 5. Minimum gap cooldown
      final minGap = state.escalationLevel >= 3
          ? const Duration(hours: 1)
          : const Duration(hours: 3);
      if (state.lastSentAt.isAfter(now.subtract(minGap))) {
        return EligibilityResult.blocked('Cooldown active (${minGap.inHours}h min gap)');
      }
    } else {
      // SOS 5-min cooldown to prevent duplicate fires
      if (state.lastSentAt.isAfter(now.subtract(const Duration(minutes: 5)))) {
        return EligibilityResult.blocked('SOS Cooldown (5m)');
      }
    }

    // NOTE: Removed "60-min user action silence window" — this was silencing
    // ALL standard notifications for active users. The IntelligenceEngine
    // handles context-awareness instead.

    return EligibilityResult.allowed();
  }

  static bool _isInQuietHours(NotificationState state, DateTime now) {
    final startParts = state.quietStart.split(':');
    final endParts = state.quietEnd.split(':');

    final startTime = DateTime(now.year, now.month, now.day,
        int.parse(startParts[0]), int.parse(startParts[1]));
    final endTime = DateTime(now.year, now.month, now.day,
        int.parse(endParts[0]), int.parse(endParts[1]));

    if (startTime.isBefore(endTime)) {
      return now.isAfter(startTime) && now.isBefore(endTime);
    } else {
      // Crosses midnight (e.g. 22:30 – 08:00)
      return now.isAfter(startTime) || now.isBefore(endTime);
    }
  }
}

class EligibilityResult {
  final bool isAllowed;
  final String? reason;

  EligibilityResult.allowed() : isAllowed = true, reason = null;
  EligibilityResult.blocked(this.reason) : isAllowed = false;

  @override
  String toString() => isAllowed ? 'Allowed' : 'Blocked: $reason';
}
