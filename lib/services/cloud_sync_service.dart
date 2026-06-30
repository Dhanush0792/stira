import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'local_storage.dart';

final cloudSyncProvider = Provider<CloudSyncService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return CloudSyncService(FirebaseFirestore.instance, authService, StorageService());
});

class CloudSyncService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  final StorageService _localStorage;

  CloudSyncService(this._firestore, this._authService, this._localStorage);

  /// Backs up the local behavioral history to the authenticated user's cloud document.
  Future<void> syncHistoryToCloud() async {
    final user = _authService.currentUser;
    if (user == null) {
      debugPrint('Cloud sync skipped: No authenticated user.');
      return;
    }

    try {
      final logs = _localStorage.getCheckinHistory();
      final relapseLogs = _localStorage.getRelapseLogs().map((dt) => dt.toIso8601String()).toList();
      final triggers = _localStorage.getRelapseTriggers();
      final dopamine = _localStorage.getDopamineEntries();
      final sleepHistory = _localStorage.getSleepHistory();
      final vault = _localStorage.getVaultFragments();
      final dangerZones = _localStorage.getDangerZones();
      final profile = _localStorage.getProfile();
      
      final prefs = Hive.box('stira_prefs');
      
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      await userDoc.set({
        'lastSync': FieldValue.serverTimestamp(),
        'checkins': logs,
        'relapse_logs': relapseLogs,
        'compassionateAutopsies': triggers,
        'dopamine_entries': dopamine,
        'sleep_history': sleepHistory,
        'vault_fragments': vault,
        'danger_zones': dangerZones,
        'profile': profile,
        'onboarding_complete': _localStorage.onboardingCompleted,
        'settings': {
          'notifications_enabled': _localStorage.notificationsEnabled,
          'biometric_enabled': _localStorage.isBiometricEnabled,
          'active_disguise': _localStorage.activeDisguise,
          'notification_state_json': prefs.get('notification_state_json'),
        },
        'achievements': {
          'longest_streak': _localStorage.longestStreak,
          'stored_stability_index': _localStorage.storedStabilityIndex,
          'first_checkin_date': _localStorage.firstCheckInDate?.toIso8601String(),
          'last_relapse_date': _localStorage.lastRelapseDate?.toIso8601String(),
          'future_you_message': _localStorage.futureYouMessage,
        },
        'metadata': {
          'affirmation_index': prefs.get('affirmation_index'),
          'affirmation_refresh_count': prefs.get('affirmation_refresh_count'),
          'last_affirmation_refresh_date': prefs.get('last_affirmation_refresh_date'),
          'weekly_report_scheduled_date': prefs.get('weekly_report_scheduled_date'),
        }
      }, SetOptions(merge: true));

      debugPrint('Cloud sync successful for user: ${user.uid}');
    } catch (e) {
      debugPrint('Cloud sync failed: $e');
    }
  }

  /// Optional: A method to restore data down to the device if this is a fresh install.
  Future<void> restoreFromCloud() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data != null) {
        final logsBox = Hive.box('stira_logs');
        final prefsBox = Hive.box('stira_prefs');

        // Restore stira_logs
        if (data['checkins'] != null) await logsBox.put('history', data['checkins']);
        if (data['relapse_logs'] != null) await logsBox.put('relapses', data['relapse_logs']);
        if (data['compassionateAutopsies'] != null) await logsBox.put('relapse_triggers', data['compassionateAutopsies']);
        if (data['dopamine_entries'] != null) await logsBox.put('dopamine_entries', data['dopamine_entries']);

        // Restore stira_prefs primitives
        if (data['profile'] != null) await prefsBox.put('profile', data['profile']);
        if (data['onboarding_complete'] != null) await prefsBox.put('onboarding_completed', data['onboarding_complete']);
        if (data['vault_fragments'] != null) await prefsBox.put('vault_fragments', data['vault_fragments']);
        if (data['danger_zones'] != null) await prefsBox.put('danger_zones', data['danger_zones']);
        
        // Restore Sleep History
        final Map<dynamic, dynamic>? sleepHistory = data['sleep_history'];
        if (sleepHistory != null) {
          for (final entry in sleepHistory.entries) {
            await prefsBox.put('sleep_${entry.key}', entry.value);
          }
        }

        // Restore Settings
        final Map<dynamic, dynamic>? settings = data['settings'];
        if (settings != null) {
          if (settings['notifications_enabled'] != null) await prefsBox.put('notifications_enabled', settings['notifications_enabled']);
          if (settings['biometric_enabled'] != null) await prefsBox.put('biometric_enabled', settings['biometric_enabled']);
          if (settings['active_disguise'] != null) await prefsBox.put('active_disguise', settings['active_disguise']);
          if (settings['notification_state_json'] != null) await prefsBox.put('notification_state_json', settings['notification_state_json']);
        }

        // Restore Achievements/Dates
        final Map<dynamic, dynamic>? achievements = data['achievements'];
        if (achievements != null) {
          if (achievements['longest_streak'] != null) await prefsBox.put('longest_streak', achievements['longest_streak']);
          if (achievements['stored_stability_index'] != null) await prefsBox.put('stored_stability_index', achievements['stored_stability_index']);
          if (achievements['first_checkin_date'] != null) await prefsBox.put('first_checkin_date', achievements['first_checkin_date']);
          if (achievements['last_relapse_date'] != null) await prefsBox.put('last_relapse_date', achievements['last_relapse_date']);
          if (achievements['future_you_message'] != null) await prefsBox.put('future_you_message', achievements['future_you_message']);
        }

        // Restore Metadata
        final Map<dynamic, dynamic>? metadata = data['metadata'];
        if (metadata != null) {
          if (metadata['affirmation_index'] != null) await prefsBox.put('affirmation_index', metadata['affirmation_index']);
          if (metadata['affirmation_refresh_count'] != null) await prefsBox.put('affirmation_refresh_count', metadata['affirmation_refresh_count']);
          if (metadata['last_affirmation_refresh_date'] != null) await prefsBox.put('last_affirmation_refresh_date', metadata['last_affirmation_refresh_date']);
          if (metadata['weekly_report_scheduled_date'] != null) await prefsBox.put('weekly_report_scheduled_date', metadata['weekly_report_scheduled_date']);
        }

        debugPrint('Cloud restore successful for user: ${user.uid}');
      }
    } catch (e) {
      debugPrint('Cloud restore failed: $e');
    }
  }
}
