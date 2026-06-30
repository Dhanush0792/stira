import 'stira_intelligence_engine.dart';
import 'local_storage.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around StiraIntelligenceEngine.
/// Kept for backward compatibility with any code that still calls AdaptiveScheduler.syncSchedule().
class AdaptiveScheduler {
  static Future<void> syncSchedule(dynamic state) async {
    final storage = StorageService();
    if (!storage.notificationsEnabled) {
      debugPrint('AdaptiveScheduler: Notifications disabled. Skipping.');
      return;
    }
    debugPrint('AdaptiveScheduler: Delegating to StiraIntelligenceEngine...');
    await StiraIntelligenceEngine.runCycle();
  }
}
