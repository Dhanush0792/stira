import "package:firebase_crashlytics/firebase_crashlytics.dart";

/// Stira error reporter - wraps Crashlytics for clean service calls.
class StiraErrorReporter {
  static final _crashlytics = FirebaseCrashlytics.instance;

  /// Call when a recoverable error occurs (will not appear as "fatal").
  static Future<void> logError(Object error, StackTrace stack, {String? reason}) async {
    await _crashlytics.recordError(error, stack,
      reason: reason ?? "non_fatal_error",
      fatal: false,
    );
  }

  /// Annotate Crashlytics with the current user ID for easier debugging.
  static Future<void> setUser(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  /// Set a custom key visible in Crashlytics dashboard.
  static Future<void> setKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// DEBUG ONLY: test crash to verify Crashlytics is reporting.
  /// Remove before production release.
  static void testCrash() {
    assert(() {
      // Only executes in debug mode due to assert()
      FirebaseCrashlytics.instance.crash();
      return true;
    }());
  }
}
