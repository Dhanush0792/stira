import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/stira_tokens.dart';
import '../services/stira_local_notification_service.dart';

class InAppNotificationBanner extends StatefulWidget {
  final VoidCallback? onTap;
  const InAppNotificationBanner({super.key, this.onTap});

  @override
  State<InAppNotificationBanner> createState() => _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  Map<String, String>? _currentNotification;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    StiraNotificationService.inAppNotificationNotifier.addListener(_onNotificationReceived);
  }

  @override
  void dispose() {
    StiraNotificationService.inAppNotificationNotifier.removeListener(_onNotificationReceived);
    _controller.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _onNotificationReceived() {
    final newNotif = StiraNotificationService.inAppNotificationNotifier.value;
    if (newNotif != null && mounted) {
      _dismissTimer?.cancel();
      setState(() {
        _currentNotification = newNotif;
      });
      _controller.forward(from: 0.0);
      _dismissTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentNotification = null;
        });
        StiraNotificationService.clearInAppNotification();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNotification == null) {
      return const SizedBox.shrink();
    }

    final title = _currentNotification!['title'] ?? 'Alert';
    final body = _currentNotification!['body'] ?? '';

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              type: MaterialType.transparency,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! < -5) {
                    _dismiss();
                  }
                },
                onTap: () {
                  _dismiss();
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: StiraTokens.stiraPink.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: StiraTokens.stiraPink.withValues(alpha: 0.15),
                        blurRadius: 28,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              children: [
                                // Logo icon
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: StiraTokens.stiraPink,
                                    boxShadow: [
                                      BoxShadow(
                                        color: StiraTokens.stiraPink.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.adjust,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'STIRA',
                                  style: GoogleFonts.syne(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white30,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'now',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    color: Colors.white38,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _dismiss,
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Content
                            Text(
                              title,
                              style: GoogleFonts.syne(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              body,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.75),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
