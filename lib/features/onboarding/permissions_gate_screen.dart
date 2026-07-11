import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../widgets/stira_background_orbs.dart';
import '../../services/stira_local_notification_service.dart';
import '../dashboard/commitment_screen.dart';

class PermissionsGateScreen extends StatefulWidget {
  const PermissionsGateScreen({super.key});

  @override
  State<PermissionsGateScreen> createState() => _PermissionsGateScreenState();
}

class _PermissionsGateScreenState extends State<PermissionsGateScreen> {
  bool _notificationsAllowed = false;
  bool _batteryExemptAllowed = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentStates();
  }

  Future<void> _checkCurrentStates() async {
    final batteryIgnored = await StiraNotificationService.isBatteryOptimizationIgnored();
    setState(() {
      _batteryExemptAllowed = batteryIgnored;
    });
  }

  Future<void> _requestNotifications() async {
    await StiraNotificationService.requestPermission();
    await StiraNotificationService.syncPermissionToStorage();
    setState(() {
      _notificationsAllowed = true;
    });
  }

  Future<void> _requestBatteryExemption() async {
    await StiraNotificationService.requestIgnoreBatteryOptimization();
    // Re-check after returning from settings page
    await Future.delayed(const Duration(milliseconds: 1000));
    await _checkCurrentStates();
  }

  void _proceedToCommitments() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CommitmentScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          const StiraBackgroundOrbs(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "System Permissions",
                    style: GoogleFonts.dmSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: StiraTokens.stiraWhite,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "To guarantee time-critical forecasting and local alert delivery, Stira needs two permissions:",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: StiraTokens.stiraMuted,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 1. Notification Permission Row
                  StiraGlassCard(
                    accentColor: _notificationsAllowed ? StiraTokens.stiraTeal : Colors.transparent,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active_outlined,
                              color: _notificationsAllowed ? StiraTokens.stiraTeal : StiraTokens.stiraWhite,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Local Alerts",
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: StiraTokens.stiraWhite,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Trigger motivational overrides and relapse preventions exactly when urges peak.",
                          style: GoogleFonts.dmSans(fontSize: 14, color: StiraTokens.stiraMuted),
                        ),
                        const SizedBox(height: 16),
                        StiraPrimaryButton(
                          label: _notificationsAllowed ? "Allowed" : "Enable Alerts",
                          color: _notificationsAllowed ? StiraTokens.stiraGlass : StiraTokens.stiraPink,
                          onTap: _notificationsAllowed ? null : _requestNotifications,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 2. Battery Exemption Row
                  StiraGlassCard(
                    accentColor: _batteryExemptAllowed ? StiraTokens.stiraTeal : Colors.transparent,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.battery_alert_outlined,
                              color: _batteryExemptAllowed ? StiraTokens.stiraTeal : StiraTokens.stiraWhite,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Nervous System Engine",
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: StiraTokens.stiraWhite,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Allows Stira to perform offline pattern calculations in the background without OS termination.",
                          style: GoogleFonts.dmSans(fontSize: 14, color: StiraTokens.stiraMuted),
                        ),
                        const SizedBox(height: 16),
                        StiraPrimaryButton(
                          label: _batteryExemptAllowed ? "Exempted" : "Ignore Battery Optimizations",
                          color: _batteryExemptAllowed ? StiraTokens.stiraGlass : StiraTokens.stiraViolet,
                          onTap: _batteryExemptAllowed ? null : _requestBatteryExemption,
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  StiraPrimaryButton(
                    label: "Continue to Commitments",
                    color: StiraTokens.stiraWhite,
                    textColor: Colors.black,
                    onTap: _proceedToCommitments,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
