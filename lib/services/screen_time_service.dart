import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:usage_stats/usage_stats.dart';

class ScreenTimeService {
  static final ScreenTimeService _instance = ScreenTimeService._internal();
  factory ScreenTimeService() => _instance;
  ScreenTimeService._internal();

  static const MethodChannel _channel = MethodChannel('com.stira.app/screen_time');

  /// Check if we have permissions to read usage stats (Android) 
  /// or FamilyControls (iOS)
  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      bool? isGranted = await UsageStats.checkUsagePermission();
      return isGranted ?? false;
    } else if (Platform.isIOS) {
      try {
        final bool isAuthorized = await _channel.invokeMethod('checkAuthorization');
        return isAuthorized;
      } on PlatformException catch (e) {
        debugPrint("Error checking iOS Screen Time auth: $e");
        return false;
      }
    }
    return false;
  }

  /// Open system settings to grant permissions
  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      await UsageStats.grantUsagePermission();
    } else if (Platform.isIOS) {
      await _channel.invokeMethod('requestAuthorization');
    }
  }

  /// Fetch usage for a specific time range. Defaults to last 24h.
  Future<Map<String, double>> getUsageStats({DateTime? startTime, DateTime? endTime}) async {
    DateTime end = endTime ?? DateTime.now();
    DateTime start = startTime ?? end.subtract(const Duration(hours: 24));
    
    // Safety check: UsageStatsManager doesn't like negative ranges
    if (start.isAfter(end)) start = end.subtract(const Duration(minutes: 1));

    if (Platform.isAndroid) {
      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(start, end);
      
      double totalMs = 0;
      double socialMs = 0;

      // Expanded social media & high-dopamine package names
      final socialPackages = {
        'com.facebook.katana',
        'com.instagram.android',
        'com.twitter.android',
        'com.zhiliaoapp.musically', // TikTok
        'com.zhiliaoapp.musically.go',
        'com.whatsapp',
        'com.google.android.youtube',
        'com.google.android.apps.youtube.music',
        'com.reddit.frontpage',
        'com.snapchat.android',
        'com.linkedin.android',
        'com.pinterest',
        'com.discord',
        'com.netflix.mediaclient',
        'com.disney.disneyplus',
      };

      for (var info in usageStats) {
        double duration = double.tryParse(info.totalTimeInForeground!) ?? 0;
        // The API sometimes returns stats for older periods if not carefully filtered,
        // but queryUsageStats usually handles it. We accumulate foreground time.
        totalMs += duration;
        if (socialPackages.contains(info.packageName)) {
          socialMs += duration;
        }
      }

      return {
        'totalHours': totalMs / 3600000,
        'socialHours': socialMs / 3600000,
      };
    } else if (Platform.isIOS) {
      // iOS FamilyControls implementation would happen via MethodChannel
      try {
        final Map<dynamic, dynamic>? stats = await _channel.invokeMethod('getUsageStats', {
          'startTime': startTime?.millisecondsSinceEpoch,
          'endTime': end.millisecondsSinceEpoch,
        });
        if (stats != null) {
          return {
            'totalHours': (stats['totalHours'] as num).toDouble(),
            'socialHours': (stats['socialHours'] as num).toDouble(),
          };
        }
      } catch (e) {
        debugPrint("Error fetching iOS Screen Time stats: $e");
      }
    }

    return {'totalHours': 0.0, 'socialHours': 0.0};
  }

  /// Helper for "Today" stats (from midnight)
  Future<Map<String, double>> getTodayUsageStats() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    return getUsageStats(startTime: midnight, endTime: now);
  }

  /// Fetches hourly segments for the graph (last 12 hours)
  Future<List<Map<String, dynamic>>> getHourlyUsageSegments() async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> segments = [];

    // Query each of the last 12 hourly segments
    for (int i = 11; i >= 0; i--) {
      final end = now.subtract(Duration(hours: i));
      final start = end.subtract(const Duration(hours: 1));
      
      final stats = await getUsageStats(startTime: start, endTime: end);
      
      segments.add({
        'hour': end.hour,
        'screenTime': (stats['totalHours']! * 60).toInt(), // Minutes
        'socialTime': (stats['socialHours']! * 60).toInt(),
      });
    }

    return segments;
  }
}
