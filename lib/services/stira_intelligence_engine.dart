import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'stira_behaviour_reader.dart';
import 'stira_throttle_manager.dart';
import 'stira_notification_messages.dart';
import 'stira_local_notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await Hive.openBox('check_ins');
    await Hive.openBox('user_data');
    await Hive.openBox('notification_state');
    await Hive.openBox('dopamine_journal');
    await Hive.openBox('commitments');
    await Hive.openBox('danger_zones');
    await Hive.openBox('stira_prefs'); // Used by throttle strictly

    if (task == 'stira_intelligence_cycle') {
      await StiraNotificationService.initialize();
      await StiraIntelligenceEngine.runCycle();
    }

    return Future.value(true);
  });
}

enum UserAction {
  checkInSubmitted,
  relapseLogged,
  commitmentSaved,
  appOpened,
  notificationTapped,
}

class StiraIntelligenceEngine {
  static Future<void> startBackgroundCycle() async {
    await Workmanager().registerPeriodicTask(
      "stira_intelligence_task",
      "stira_intelligence_cycle",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresDeviceIdle: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static Future<void> runCycle() async {
    final snapshot = StiraBehaviourReader.snapshot();
    final prefs = Hive.box('stira_prefs');
    final now = DateTime.now();

    // Step 1: Midnight Reset (Built-in to canSend)
    StiraThrottleManager.canSend(isCrisis: false);

    // Step 2: Crisis Urge Velocity
    if (snapshot.urgeVelocity >= 3.0 && snapshot.checkedInToday) {
      final msg = StiraNotificationMessages.urgeVelocity(snapshot);
      await StiraNotificationService.showNow(
        StiraNotificationService.ID_URGE_VELOCITY,
        msg['title']!, msg['body']!, "stira_critical", msg['payload']!,
        showInApp: false,
      );
      StiraThrottleManager.recordSent();
      return;
    }

    // Step 3: Milestone
    final List<int> milestones = [3, 7, 14, 30, 60, 90, 180, 365];
    if (milestones.contains(snapshot.currentStreak)) {
      final int lastMilestoneFired = prefs.get('last_milestone_fired', defaultValue: -1);
      if (lastMilestoneFired != snapshot.currentStreak) {
        final msg = StiraNotificationMessages.streakMilestone(snapshot.currentStreak, snapshot.userName);
        await StiraNotificationService.showNow(
          StiraNotificationService.ID_STREAK_MILESTONE,
          msg['title']!, msg['body']!, "stira_high", msg['payload']!,
          showInApp: false,
        );
        prefs.put('last_milestone_fired', snapshot.currentStreak);
        StiraThrottleManager.recordSent();
        return;
      }
    }

    // Step 4: Pre-Milestone
    if (milestones.contains(snapshot.currentStreak + 1) && now.hour >= 19 && now.hour <= 21) {
      if (StiraThrottleManager.canSend()) {
        final msg = StiraNotificationMessages.preMilestone(snapshot.currentStreak + 1);
        await StiraNotificationService.showNow(
          StiraNotificationService.ID_PRE_MILESTONE,
          msg['title']!, msg['body']!, "stira_high", msg['payload']!,
          showInApp: false,
        );
        StiraThrottleManager.recordSent();
        return;
      }
    }

    // Step 5: Same Time Tomorrow
    if (snapshot.sameTimeTomorrowDue) {
      if (StiraThrottleManager.canSend()) {
        final msg = StiraNotificationMessages.sameTimeTomorrow(snapshot.userName, snapshot.commitmentText);
        await StiraNotificationService.showNow(
          StiraNotificationService.ID_SAME_TIME_TOMORROW,
          msg['title']!, msg['body']!, "stira_high", msg['payload']!,
          showInApp: false,
        );
        StiraThrottleManager.recordSent();
        return;
      }
    }

    // Step 6: Predictive Vulnerability Warning
    int minutesUntilPeakHour = (snapshot.peakHour * 60) - (now.hour * 60 + now.minute);
    
    // Convert to positive distance if negative (not strictly asked but logical context of "until")
    if (minutesUntilPeakHour < 0) minutesUntilPeakHour += 24 * 60; 

    if (minutesUntilPeakHour >= 30 && minutesUntilPeakHour <= 50 && snapshot.peakHourConfidence >= 45) {
      if (StiraThrottleManager.canSend()) {
        final msg = StiraNotificationMessages.vulnerabilityWarning(snapshot);
        await StiraNotificationService.showNow(
          StiraNotificationService.ID_VULNERABILITY_WARNING,
          msg['title']!, msg['body']!, "stira_high", msg['payload']!,
          showInApp: false,
        );
        StiraThrottleManager.recordSent();
        return;
      }
    }

    // Step 7: Check-in Reminder
    if (!snapshot.checkedInToday && snapshot.hoursSinceLastCheckIn < 48) {
      // Calculate scheduling time: 30 minutes before peak hour
      final scheduledTime = now.isBefore(DateTime(now.year, now.month, now.day, snapshot.peakHour).subtract(const Duration(minutes: 30)))
          ? DateTime(now.year, now.month, now.day, snapshot.peakHour).subtract(const Duration(minutes: 30))
          : null;

      if (scheduledTime != null) {
        final msg = StiraNotificationMessages.checkInReminder(snapshot);
        await StiraNotificationService.scheduleAt(
          StiraNotificationService.ID_CHECKIN_REMINDER,
          msg['title']!, msg['body']!, scheduledTime, "stira_high", msg['payload']!
        );
      } else {
        // If we are already deep in the window, only showNow if not recently opened
        final lastOpen = prefs.get('last_app_open_at', defaultValue: '');
        bool tooSoon = false;
        if (lastOpen.isNotEmpty) {
          final dt = DateTime.tryParse(lastOpen);
          if (dt != null && now.difference(dt).inMinutes < 60) tooSoon = true;
        }

        int minutesToPeak = ((snapshot.peakHour - now.hour) * 60);
        if (minutesToPeak <= 60 && minutesToPeak >= -30 && !tooSoon) {
          if (StiraThrottleManager.canSend()) {
            final msg = StiraNotificationMessages.checkInReminder(snapshot);
            await StiraNotificationService.showNow(
              StiraNotificationService.ID_CHECKIN_REMINDER,
              msg['title']!, msg['body']!, "stira_high", msg['payload']!,
              showInApp: false,
            );
            StiraThrottleManager.recordSent();
            return;
          }
        }
      }
    }

    // Step 8: Disengagement
    if (snapshot.hoursSinceLastCheckIn >= 72) {
      if (StiraThrottleManager.canSend()) {
        final msg = StiraNotificationMessages.disengagement72h(snapshot);
        await StiraNotificationService.showNow(
          StiraNotificationService.ID_DISENGAGEMENT_72H,
          msg['title']!, msg['body']!, "stira_low", msg['payload']!,
          showInApp: false,
        );
        StiraThrottleManager.recordSent();
        return;
      }
    } else if (snapshot.hoursSinceLastCheckIn >= 48) {
      if (StiraThrottleManager.canSend()) {
        final msg = StiraNotificationMessages.disengagement48h(snapshot);
        await StiraNotificationService.showNow(
          StiraNotificationService.ID_DISENGAGEMENT_48H,
          msg['title']!, msg['body']!, "stira_low", msg['payload']!,
          showInApp: false,
        );
        StiraThrottleManager.recordSent();
        return;
      }
    }

    // Step 9: Dopamine Journal
    if (!snapshot.dopamineJournalToday && now.hour == 21) {
      if (StiraThrottleManager.canSend()) {
        final msg = StiraNotificationMessages.dopamineJournal();
        await StiraNotificationService.showNow(
          StiraNotificationService.ID_DOPAMINE_JOURNAL,
          msg['title']!, msg['body']!, "stira_low", msg['payload']!,
          showInApp: false,
        );
        StiraThrottleManager.recordSent();
        return;
      }
    }

    // Step 10: Identity Push
    if (snapshot.sentToday == 0 && now.hour == snapshot.peakHour) {
      if (StiraThrottleManager.canSend()) {
        final msg = StiraNotificationMessages.identityPush(snapshot.daysSinceInstall);
        await StiraNotificationService.showNow(
          StiraNotificationService.ID_IDENTITY_PUSH,
          msg['title']!, msg['body']!, "stira_low", msg['payload']!,
          showInApp: false,
        );
        StiraThrottleManager.recordSent();
        return;
      }
    }

    // Step 11: Weekly Report
    if (now.weekday == DateTime.sunday && now.hour == 8) {
      final String? lastReportStr = prefs.get('last_weekly_report_sent');
      final todayDateStr = '${now.year}-${now.month}-${now.day}';
      if (lastReportStr != todayDateStr) {
        if (StiraThrottleManager.canSend()) {
          final msg = StiraNotificationMessages.weeklyReport();
          await StiraNotificationService.showNow(
            StiraNotificationService.ID_WEEKLY_REPORT,
            msg['title']!, msg['body']!, "stira_low", msg['payload']!,
            showInApp: false,
          );
          prefs.put('last_weekly_report_sent', todayDateStr);
          StiraThrottleManager.recordSent();
          return;
        }
      }
    }

    // Step 12: Stability Improving
    if (snapshot.stabilityTrend > 0.5) {
      final String? lastStabilityStr = prefs.get('last_stability_notif');
      bool canSendStability = true;
      if (lastStabilityStr != null) {
        final last = DateTime.tryParse(lastStabilityStr);
        if (last != null && now.difference(last).inDays <= 7) {
          canSendStability = false;
        }
      }
      
      if (canSendStability && StiraThrottleManager.canSend()) {
        final msg = StiraNotificationMessages.stabilityImproving(snapshot);
        await StiraNotificationService.showNow(
          StiraNotificationService.ID_STABILITY_UP,
          msg['title']!, msg['body']!, "stira_low", msg['payload']!,
          showInApp: false,
        );
        prefs.put('last_stability_notif', now.toIso8601String());
        StiraThrottleManager.recordSent();
        return;
      }
    }
  }

  static Future<void> reactToAction(UserAction action) async {
    await StiraNotificationService.initialize();

    if (action == UserAction.checkInSubmitted) {
      StiraNotificationService.cancel(StiraNotificationService.ID_CHECKIN_REMINDER);
      StiraNotificationService.cancel(StiraNotificationService.ID_DISENGAGEMENT_48H);
      StiraNotificationService.cancel(StiraNotificationService.ID_DISENGAGEMENT_72H);

      final checkIns = Hive.box('check_ins');
      if (checkIns.isNotEmpty) {
        final allCheckIns = checkIns.values.cast<Map>().toList();
        allCheckIns.sort((a, b) {
          final ta = DateTime.tryParse(a['timestamp'] as String? ?? '') ?? DateTime(2000);
          final tb = DateTime.tryParse(b['timestamp'] as String? ?? '') ?? DateTime(2000);
          return tb.compareTo(ta); // newest first
        });
        
        final latest = allCheckIns.first;
        final int urgeLevel = (latest['urge'] as num?)?.toInt() ?? 0;
        
        if (urgeLevel >= 8) {
          StiraThrottleManager.setCrisisActive(true);
          StiraNotificationService.fireSOSHeartbeat();
        } else {
          StiraThrottleManager.setCrisisActive(false);
        }
      }

      // Offload heavy calculation and scheduling to background to avoid blocking the UI transition
      unawaited(() async {
        try {
          final snapshot = StiraBehaviourReader.snapshot();
          final msg = StiraNotificationMessages.checkInFollowUp(snapshot);
          await StiraNotificationService.scheduleAt(
            StiraNotificationService.ID_CHECKIN_FOLLOWUP,
            msg['title']!, msg['body']!, DateTime.now().add(const Duration(hours: 4)),
            "stira_low", msg['payload']!
          );
        } catch (e) {
          debugPrint('Background follow-up scheduling failed: $e');
        }
      }());

    } else if (action == UserAction.relapseLogged) {
      final userData = Hive.box('user_data');
      userData.put('last_relapse_at', DateTime.now().toIso8601String());
      
      final snapshot = StiraBehaviourReader.snapshot();
      final msg = StiraNotificationMessages.relapseSupport(snapshot);
      
      await StiraNotificationService.showNow(
        StiraNotificationService.ID_RELAPSE_SUPPORT,
        msg['title']!, msg['body']!, "stira_critical", msg['payload']!,
        showInApp: true,
      );
      
      StiraThrottleManager.recordSent();
      StiraThrottleManager.setCrisisActive(false);

    } else if (action == UserAction.commitmentSaved) {
      final commitments = Hive.box('commitments');
      if (commitments.isNotEmpty) {
        final recent = commitments.values.last as Map?;
        if (recent != null) {
          final String text = recent['text'] as String? ?? recent['commitment'] as String? ?? '';
          final snapshot = StiraBehaviourReader.snapshot();
          final msg = StiraNotificationMessages.sameTimeTomorrow(snapshot.userName, text);
          StiraNotificationService.scheduleAt(
            StiraNotificationService.ID_SAME_TIME_TOMORROW,
            msg['title']!, msg['body']!, DateTime.now().add(const Duration(hours: 24)),
            "stira_high", msg['payload']!
          );
        }
      }

    } else if (action == UserAction.appOpened) {
      final prefs = Hive.box('stira_prefs');
      prefs.put('last_app_open_at', DateTime.now().toIso8601String());
      
      StiraNotificationService.cancel(StiraNotificationService.ID_DISENGAGEMENT_48H);
      StiraNotificationService.cancel(StiraNotificationService.ID_DISENGAGEMENT_72H);
      StiraNotificationService.cancel(StiraNotificationService.ID_CHECKIN_REMINDER);
      StiraThrottleManager.recordTap();
    } else if (action == UserAction.notificationTapped) {
      StiraThrottleManager.recordTap();
    }
  }
}
