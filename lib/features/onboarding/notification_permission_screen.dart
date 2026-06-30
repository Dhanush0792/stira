import 'package:flutter/material.dart';
import '../../core/theme/earth_night.dart';
import '../../core/common_widgets/stira_widgets.dart';
import '../../services/local_storage.dart';
import '../../services/stira_local_notification_service.dart';
import '../navigation/main_navigation.dart';

/// Shown once after onboarding completion.
/// Requests notification permission in a calm, non-pressuring way.
class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  Future<void> _allow(BuildContext context) async {
    await StiraNotificationService.requestPermission();
    final storage = StorageService();
    await storage.setNotificationPermissionAsked();
    await storage.setNotificationsEnabled(true);
    if (!context.mounted) return;
    _navigateMain(context);
  }

  Future<void> _notNow(BuildContext context) async {
    final storage = StorageService();
    await storage.setNotificationPermissionAsked();
    if (!context.mounted) return;
    _navigateMain(context);
  }

  void _navigateMain(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigation(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon orb
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EarthNight.accentViolet.withValues(alpha: 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: EarthNight.accentViolet.withValues(alpha: 0.14),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: EarthNight.accentViolet,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Predictive Interventions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: EarthNight.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Stira uses notifications to warn before high-intensity windows.\n\nIf you deny these, the app will still function offline, but predictive alerts cannot be delivered.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: EarthNight.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                StiraButton(
                  text: 'Allow Reminders',
                  onPressed: () => _allow(context),
                ),
                const SizedBox(height: 12),
                StiraButton(
                  text: 'Not Now',
                  isSecondary: true,
                  onPressed: () => _notNow(context),
                ),
                const SizedBox(height: 32),
                const Text(
                  'You can change this anytime in Profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: EarthNight.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
