import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

import '../../../theme/stira_tokens.dart';
import '../../../widgets/stira_glass_card.dart';
import '../../../widgets/stira_led_metric.dart';
import '../../../widgets/stira_card_label.dart';
import '../../../widgets/stira_orb.dart';
import '../../../core/intelligence_layer.dart';
import '../../../services/local_storage.dart';
import '../../../services/stira_local_notification_service.dart';
import '../../../core/common_widgets/placeholder_screen.dart';
import '../../reflection/future_you_screen.dart';
import '../../profile/identity_builder_screen.dart';
import '../../vault/vault_screen.dart';
import '../../profile/shadow_mode_settings_screen.dart';
import '../../profile/streak_insurance_screen.dart';
import '../../../services/export_service.dart';
import '../../reports/weekly_report_screen.dart';
import '../../../services/stira_auth_service.dart';
import '../../../core/auth_wrapper.dart';
import '../../../core/tour/stira_info_icon.dart';
import '../../../core/tour/stira_tour_controller.dart';
import '../../profile/legal_support_screens.dart';

/// Tab 3 — Profile (Stira v2 — migrated to StiraTokens)
/// Bug #09 fixed: ALL menu items have subtitles and uniform style
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = Hive.box('stira_prefs');
    final storage = StorageService();
    final state = ref.watch(intelligenceProvider);
    final isGuest = storage.isGuestMode;
    // Bug Fix #1: Use Firebase Auth display name as fallback so name is never 'You'
    final firebaseDisplayName = FirebaseAuth.instance.currentUser?.displayName;
    final profileName = (storage.getProfile()?['name'] as String?);
    final name = (profileName?.isNotEmpty == true ? profileName : firebaseDisplayName)
        ?? (isGuest ? 'Guest' : 'You');
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final streak = state.streak;
    final stability = state.stabilityIndex;
    final checkins = state.totalCheckins;

    final firstDate = storage.firstCheckInDate;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final memberSince = firstDate != null
        ? '${months[firstDate.month - 1]} ${firstDate.year}'
        : 'Recently';

    return Container(
      color: StiraTokens.stiraBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Profile gradient: stiraBg2 (top) → stiraBg (bottom), no radial overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [StiraTokens.stiraBg2, StiraTokens.stiraBg],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: RepaintBoundary(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar section ─────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: StiraTokens.stiraPink.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                    ),
                                  ],
                                ),
                              ),
                              const StiraOrb(size: 60, intensity: 0.5),
                              Text(
                                initial,
                                style: GoogleFonts.syne(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: GoogleFonts.syne(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: StiraTokens.stiraWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Member since $memberSince',
                          style: GoogleFonts.dmMono(
                            fontSize: 9,
                            color: StiraTokens.stiraMuted,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Stats row (3 equal StiraGlassCards) ───────
                  Row(
                    children: [
                      Expanded(
                        child: StiraGlassCard(
                          accentColor: StiraTokens.stiraPink,
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StiraLedMetric(
                                value: '$streak',
                                color: StiraTokens.stiraPink,
                                size: 18,
                              ),
                              const SizedBox(height: 2),
                              const StiraCardLabel('DAY STREAK'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StiraGlassCard(
                          accentColor: StiraTokens.stiraTeal,
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StiraLedMetric(
                                value: '$stability',
                                unit: '%',
                                color: StiraTokens.stiraTeal,
                                size: 18,
                              ),
                              const SizedBox(height: 2),
                              const StiraCardLabel('STABILITY'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StiraGlassCard(
                          accentColor: StiraTokens.stiraAmber,
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StiraLedMetric(
                                value: '$checkins',
                                color: StiraTokens.stiraAmber,
                                size: 18,
                              ),
                              const SizedBox(height: 2),
                              const StiraCardLabel('CHECK-INS'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Guest Mode Banner ────────────────────────────
                  if (isGuest) ...[
                    _GuestBanner(
                      onSignIn: () async {
                        await StiraAuthService().logoutUser();
                        if (!context.mounted) return;
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthWrapper()),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Menu items — ALL identical style + subtitles ─
                  // Bug #09 fix: every item has subtitle, same glass card style
                  ValueListenableBuilder(
                    valueListenable:
                        prefs.listenable(keys: ['notifications_enabled']),
                    builder: (context, _, __) {
                      final enabled = storage.notificationsEnabled;
                      return _MenuItem(
                        emoji: '🔔',
                        name: 'Daily Reminders',
                        subtitle: enabled ? '8 AM · 10 PM' : 'Off',
                        featureId: 'notifications_settings',
                        trailing: CupertinoSwitch(
                          value: enabled,
                          activeTrackColor: StiraTokens.stiraPink,
                          onChanged: (val) async {
                            if (val) {
                              final status = await Permission.notification.request();
                              if (!status.isGranted) {
                                await storage.setNotificationsEnabled(false);
                                return;
                              }
                              await StiraNotificationService.requestPermission();
                            }
                            await storage.setNotificationsEnabled(val);
                            await StiraNotificationService.syncPermissionToStorage();
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable:
                        prefs.listenable(keys: ['biometric_enabled']),
                    builder: (context, _, __) {
                      final enabled = storage.isBiometricEnabled;
                      return _MenuItem(
                        emoji: '🔐',
                        name: 'Biometric App Lock',
                        subtitle: enabled ? 'FaceID enabled' : 'Disabled',
                        trailing: CupertinoSwitch(
                          value: enabled,
                          activeTrackColor: StiraTokens.stiraPink,
                          onChanged: (val) async {
                            if (val) {
                              final auth = LocalAuthentication();
                              try {
                                final canCheck = await auth.canCheckBiometrics || await auth.isDeviceSupported();
                                if (!canCheck) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Biometrics not available or supported on this device.'),
                                      backgroundColor: StiraTokens.stiraPink,
                                    ),
                                  );
                                  return;
                                }
                                final authenticated = await auth.authenticate(
                                  localizedReason: 'Confirm to enable biometric lock',
                                  options: const AuthenticationOptions(
                                    stickyAuth: true,
                                    biometricOnly: false,
                                  ),
                                );
                                if (!authenticated) return;
                              } catch (e) {
                                debugPrint('Biometric setup failed: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Setup failed: $e'),
                                    backgroundColor: StiraTokens.stiraPink,
                                  ),
                                );
                                return;
                              }
                            }
                            await storage.setBiometricEnabled(val);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Section 6A fix: subtitle = "Letters to your future self"
                  _MenuItem(
                    emoji: '🗝️',
                    name: 'The Vault',
                    subtitle: 'Letters to your future self',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VaultScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    emoji: '🧬',
                    name: 'Identity Builder',
                    subtitle: 'Define who you are becoming',
                    featureId: 'identity_builder',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const IdentityBuilderScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    emoji: '🛡️',
                    name: 'Streak Insurance',
                    subtitle: 'Protect your progress',
                    featureId: 'streak_insurance',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const StreakInsuranceScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bug fix: Weekly Report — same style (no purple highlight)
                  _MenuItem(
                    emoji: '📊',
                    name: 'Weekly Report',
                    subtitle: 'Your full behavioral review',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => WeeklyReportScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    emoji: '📤',
                    name: 'Export Data',
                    subtitle: 'Download as CSV',
                    onTap: () => ExportService().exportClinicalData(),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    emoji: '🧭',
                    name: 'App Guide',
                    subtitle: 'Replay the onboarding tour',
                    onTap: () {
                      ref.read(tourControllerProvider.notifier).resetTour();
                    },
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    emoji: '❓',
                    name: 'Support & FAQs',
                    subtitle: 'Help center and contact options',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LegalSupportScreen(initialTabIndex: 0)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    emoji: '📄',
                    name: 'Privacy & Terms',
                    subtitle: 'Legal details and privacy policy',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LegalSupportScreen(initialTabIndex: 2)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: StiraTokens.stiraGlassBorder, height: 1),
                  const SizedBox(height: 12),
                  if (isGuest) ...[
                    _MenuItem(
                      emoji: '🔑',
                      name: 'Sign In to Stira',
                      subtitle: 'Sync your data across devices',
                      nameColor: StiraTokens.stiraTeal,
                      onTap: () async {
                        await StiraAuthService().logoutUser();
                        if (!context.mounted) return;
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthWrapper()),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      emoji: '🗑️',
                      name: 'Clear All Local Data',
                      subtitle: 'Permanently erase all data from this device',
                      nameColor: const Color(0xFFFF3B30).withValues(alpha: 0.8),
                      onTap: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const GuestDataDeletionScreen(),
                      ),
                    ),
                  ] else ...[
                    _MenuItem(
                      emoji: '🚪',
                      name: 'Sign Out',
                      subtitle: 'End session',
                      nameColor: StiraTokens.stiraPink.withValues(alpha: 0.7),
                      onTap: () async {
                        await StiraAuthService().logoutUser();
                        if (!context.mounted) return;
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthWrapper()),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      emoji: '⚠️',
                      name: 'Delete Account',
                      subtitle: 'Permanently remove all data',
                      nameColor: const Color(0xFFFF3B30).withValues(alpha: 0.8),
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _DeleteAccountDialog(),
    );
  }
}

/// Profile menu item — uniform style, always has subtitle.
/// Fixes Bug #09: Profile menu items have no subtitles
class _MenuItem extends StatelessWidget {
  final String emoji;
  final String name;
  final String subtitle;
  final Color? nameColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? featureId;

  const _MenuItem({
    required this.emoji,
    required this.name,
    required this.subtitle,
    this.nameColor,
    this.onTap,
    this.trailing,
    this.featureId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: StiraGlassCard(
        // All items same glass style — no accent color differentiation per spec
        accentColor: StiraTokens.stiraGlassBorder.withValues(alpha: 0.5),
        fullWidth: true,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: StiraTokens.stiraGlass,
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: nameColor ?? StiraTokens.stiraWhite,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                          fontSize: 10, color: StiraTokens.stiraMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (featureId != null) ...[
              StiraInfoIcon(featureId: featureId!),
              const SizedBox(width: 8),
            ],
            trailing ??
                Icon(Icons.chevron_right,
                    color: StiraTokens.stiraMuted.withValues(alpha: 0.5),
                    size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Delete Account Dialog ────────────────────────────────────────────────────



class _DeleteAccountDialog extends StatefulWidget {
  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _deleting = false;
  String? _error;

  Future<void> _confirmDelete() async {
    setState(() {
      _deleting = true;
      _error = null;
    });

    final result = await StiraAuthService().deleteAccount();

    if (!mounted) return;

    if (result.success) {
      // Navigate to auth screen — all data has been deleted.
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } else {
      setState(() {
        _error = result.errorMessage;
        _deleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext dialogContext) {
    return Dialog(
      backgroundColor: StiraTokens.stiraBg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF3B30),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Delete Account',
              style: GoogleFonts.syne(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: StiraTokens.stiraWhite,
              ),
            ),
            const SizedBox(height: 10),

            // Warning message
            Text(
              'This will permanently delete your account and all associated data.\n\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: StiraTokens.stiraMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'All streaks, check-ins, vault entries, and behavioral history will be lost forever.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFFFF3B30).withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFFFF3B30),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Delete button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _deleting ? null : _confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                  foregroundColor: const Color(0xFFFF3B30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.4),
                    ),
                  ),
                  elevation: 0,
                ),
                child: _deleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF3B30),
                        ),
                      )
                    : Text(
                        'Delete My Account',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: _deleting ? null : () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    color: StiraTokens.stiraMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Guest Mode Banner ────────────────────────────────────────────────────────
//
// Shown in ProfileTab when the user is in guest mode.
// Communicates limitations clearly and offers a frictionless Sign-In CTA.
// ─────────────────────────────────────────────────────────────────────────────

class _GuestBanner extends StatelessWidget {
  final VoidCallback onSignIn;
  const _GuestBanner({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            StiraTokens.stiraTeal.withValues(alpha: 0.10),
            StiraTokens.stiraViolet.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: StiraTokens.stiraTeal.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StiraTokens.stiraTeal.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              color: StiraTokens.stiraTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest Mode',
                  style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: StiraTokens.stiraTeal,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sign in to back up your progress and unlock Bond Mode.',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: StiraTokens.stiraMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // CTA
          GestureDetector(
            onTap: onSignIn,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: StiraTokens.stiraTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: StiraTokens.stiraTeal.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: StiraTokens.stiraTeal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
