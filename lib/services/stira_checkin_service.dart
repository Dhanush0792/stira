import "package:cloud_firestore/cloud_firestore.dart";
import 'stira_streak_service.dart';
import 'stira_analytics_service.dart';
import 'local_storage.dart';
import '../core/intelligence_layer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StiraCheckInService {
  final _db = FirebaseFirestore.instance;
  final _streak = StiraStreakService();
  final _analytics = StiraAnalyticsService();

  Future<void> submitCheckIn({
    required String userId,
    required int    urgeLevel,       // 1-10 from radial dial
    required List<String> triggers,  // multi-select chip values
    required String location,
    required String mood,
    String note = "",
  }) async {
    final batch = _db.batch();

    // 1. Write check-in document to Firestore
    final checkInRef = _db
        .collection("users")
        .doc(userId)
        .collection("checkin_logs")

        .doc();

    batch.set(checkInRef, {
      "timestamp":   FieldValue.serverTimestamp(),
      "urge_level":  urgeLevel,
      "triggers":    triggers,
      "location":    location,
      "mood":        mood,
      "note":        note,
      "forecast_used": false,
    });

    // 2. Update status on user document
    final userRef = _db.collection("users").doc(userId);
    batch.update(userRef, {
      "last_checkin_date": FieldValue.serverTimestamp(),
      "current_urge_level": urgeLevel,
    });

    await batch.commit();

    // 3. Recalculate streak (separate write to avoid batch conflict)
    await _streak.updateStreak(userId);

    // 4. Fire analytics event
    await _analytics.logUrgeCheckedIn(urgeLevel: urgeLevel, triggers: triggers);

    // 5. Sync to Local Hive (Phase 14 fix)
    await StorageService().addLog({
      "timestamp": DateTime.now().toIso8601String(),
      "urge_level": urgeLevel,
      "triggers": triggers,
      "location": location,
      "mood": mood,
      "note": note,
    });
  }
}
