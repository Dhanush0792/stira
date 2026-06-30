import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class StiraNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const int ID_CHECKIN_REMINDER = 101;
  static const int ID_CHECKIN_FOLLOWUP = 102;
  static const int ID_VULNERABILITY_WARNING = 103;
  static const int ID_URGE_VELOCITY = 104;
  static const int ID_DANGER_ZONE = 105;
  static const int ID_SAFE_ZONE = 106;
  static const int ID_STREAK_MILESTONE = 107;
  static const int ID_PRE_MILESTONE = 108;
  static const int ID_PERSONAL_BEST = 109;
  static const int ID_RELAPSE_SUPPORT = 110;
  static const int ID_DISENGAGEMENT_48H = 111;
  static const int ID_DISENGAGEMENT_72H = 112;
  static const int ID_DOPAMINE_JOURNAL = 113;
  static const int ID_IDENTITY_PUSH = 114;
  static const int ID_WEEKLY_REPORT = 115;
  static const int ID_SAME_TIME_TOMORROW = 116;
  static const int ID_MORNING_ANCHOR = 117;
  static const int ID_STABILITY_UP = 118;

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse notificationResponse) async {
    if (notificationResponse.payload != null) {
      await Hive.initFlutter();
      final prefs = await Hive.openBox('stira_prefs');
      await prefs.put('pending_notification_tap', notificationResponse.payload);
    }
  }

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_notification');
    
    // Do not request immediately on iOS, let requestPermission() handle it
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false);

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await (_plugin as dynamic).initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final prefs = Hive.box('stira_prefs');
          prefs.put('pending_notification_tap', response.payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create Channels
    final flutterLocalNotificationsPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (flutterLocalNotificationsPlugin != null) {
      const AndroidNotificationChannel criticalChannel = AndroidNotificationChannel(
        'stira_critical', 'Stira Alerts',
        importance: Importance.max, enableVibration: true, playSound: true,
      );
      const AndroidNotificationChannel highChannel = AndroidNotificationChannel(
        'stira_high', 'Stira Reminders',
        importance: Importance.high, enableVibration: true, playSound: true,
      );
      const AndroidNotificationChannel lowChannel = AndroidNotificationChannel(
        'stira_low', 'Stira Updates',
        importance: Importance.defaultImportance, enableVibration: false, playSound: true,
      );

      await flutterLocalNotificationsPlugin.createNotificationChannel(criticalChannel);
      await flutterLocalNotificationsPlugin.createNotificationChannel(highChannel);
      await flutterLocalNotificationsPlugin.createNotificationChannel(lowChannel);
    }
  }

  static Future<void> requestPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> showNow(int id, String title, String body, String channelId, String payload) async {
    await _plugin.cancel(id: id);
    
    String channelName = 'Stira Updates';
    if (channelId == 'stira_critical') channelName = 'Stira Alerts';
    if (channelId == 'stira_high') channelName = 'Stira Reminders';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId, channelName,
      styleInformation: BigTextStyleInformation(body),
    );
    final NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await _plugin.show(id: id, title: title, body: body, notificationDetails: details, payload: payload);
  }

  static Future<void> scheduleAt(int id, String title, String body, DateTime when, String channelId, String payload) async {
    await _plugin.cancel(id: id);
    
    String channelName = 'Stira Updates';
    if (channelId == 'stira_critical') channelName = 'Stira Alerts';
    if (channelId == 'stira_high') channelName = 'Stira Reminders';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId, channelName,
      styleInformation: BigTextStyleInformation(body),
    );
    final NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> fireSOSHeartbeat() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(pattern: [0, 100, 100, 100, 100, 100, 200, 600, 200, 100, 100, 100, 100, 100]);
    }
  }

  static Future<void> registerFcmToken() async {
    // Legacy support for navigation/auth
  }

  static Future<void> syncPermissionToStorage() async {
    final status = await Permission.notification.status;
    final prefs = Hive.box('stira_prefs');
    await prefs.put('notifications_enabled', status.isGranted);
  }
}
