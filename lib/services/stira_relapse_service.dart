import "package:cloud_firestore/cloud_firestore.dart";
import 'stira_streak_service.dart';
import 'stira_analytics_service.dart';

class StiraRelapseService {
  final _db        = FirebaseFirestore.instance;
  final _streak    = StiraStreakService();
  final _analytics = StiraAnalyticsService();

  /// Logs a relapse event.
  /// useInsurance: true = streak preserved, false = streak reset to 0.
  Future<void> logRelapse({
    required String userId,
    required String trigger,
    required bool   useInsurance,
    String note              = "",
    String preventionInsight = "",
  }) async {
    // 1. Get current streak before any reset
    final doc = await _db.collection("users").doc(userId).get();
    final streakAtRelapse = (doc.data()!["current_streak"] as int?) ?? 0;

    // 2. Write relapse document
    await _db
        .collection("users")
        .doc(userId)
        .collection("relapse_logs")
        .add({
      "timestamp":           FieldValue.serverTimestamp(),
      "trigger":             trigger,
      "note":                note,
      "prevention_insight":  preventionInsight,
      "streak_at_relapse":   streakAtRelapse,
      "insurance_activated": useInsurance,
    });

    // 3. Reset or protect streak
    if (useInsurance) {
      await _streak.activateInsurance(userId);
    } else {
      await _streak.resetStreak(userId);
    }

    // 4. Fire analytics event
    await _analytics.logRelapseEvent(
      trigger: trigger,
      streakAtRelapse: streakAtRelapse,
      insuranceUsed: useInsurance,
    );
  }

  /// Fetches all relapse logs for pattern analysis (used in Insights tab).
  Future<List<Map<String, dynamic>>> getRelapseLogs(String userId) async {
    final snap = await _db
        .collection("users")
        .doc(userId)
        .collection("relapse_logs")
        .orderBy("timestamp", descending: true)
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }
}
