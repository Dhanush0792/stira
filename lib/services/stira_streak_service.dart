import "package:cloud_firestore/cloud_firestore.dart";

class StiraStreakService {
  final _db = FirebaseFirestore.instance;

  /// Called after every check-in submission.
  /// Compares last_checkin_date to today.
  /// If check-in was today or yesterday — streak continues.
  Future<void> updateStreak(String userId) async {
    final doc = await _db.collection("users").doc(userId).get();
    final data = doc.data()!;
    final lastCheckin = (data["last_checkin_date"] as Timestamp?)?.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int currentStreak = (data["current_streak"] as int?) ?? 0;
    int longestStreak = (data["longest_streak"] as int?) ?? 0;
    int totalClean    = (data["total_clean_days"] as int?) ?? 0;

    if (lastCheckin == null) {
      // First ever check-in — start streak at 1
      currentStreak = 1;
      totalClean    = 1;
    } else {
      final lastDay = DateTime(lastCheckin.year, lastCheckin.month, lastCheckin.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 0) {
        // Already checked in today - no change to streak
      } else if (diff == 1) {
        // Checked in yesterday — extend streak
        currentStreak++;
        totalClean++;
      } else {
        // Gap of 2+ days without relapse — reset streak (missed days)
        // NOTE: Only reset if no check-in exists for yesterday.
        // This handles cases where user forgot to check in.
        // If a relapse was logged instead, resetStreak() handles it.
        currentStreak = 1;
        totalClean++;
      }
    }

    // Update longest streak if current exceeds it
    if (currentStreak > longestStreak) longestStreak = currentStreak;

    // Check streak insurance eligibility (Earned exactly on milestones)
    int insurance = (data["streak_insurance_available"] as int?) ?? 0;
    if (currentStreak == 14) insurance += 1;
    if (currentStreak == 30) insurance += 1;
    if (currentStreak == 60) insurance += 1;

    await _db.collection("users").doc(userId).update({
      "current_streak":  currentStreak,
      "longest_streak":  longestStreak,
      "total_clean_days": totalClean,
      "streak_insurance_available": insurance,
    });
  }

  /// Called when user logs a relapse without using Streak Insurance.
  Future<void> resetStreak(String userId) async {
    await _db.collection("users").doc(userId).update({
      "current_streak":  0,
      "current_urge_level": 0,
      "last_relapse_date": FieldValue.serverTimestamp(),
      // total_clean_days and longest_streak are preserved - never erased
    });
  }

  /// Called when Streak Insurance is activated.
  /// Relapse is logged but streak counter does NOT reset.
  Future<void> activateInsurance(String userId) async {
    final doc = await _db.collection("users").doc(userId).get();
    final available = (doc.data()!["streak_insurance_available"] as int?) ?? 0;

    if (available <= 0) return; // no insurance to activate

    await _db.collection("users").doc(userId).update({
      "streak_insurance_available": available - 1,
      "streak_insurance_used_at": FieldValue.serverTimestamp(),
      "last_relapse_date": FieldValue.serverTimestamp(),
      // current_streak intentionally NOT reset
    });
  }
}
