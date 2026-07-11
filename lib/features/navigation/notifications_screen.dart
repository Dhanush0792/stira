import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../services/local_storage.dart';
import 'package:google_fonts/google_fonts.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final history = storage.getNotificationHistory();

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: StiraTokens.displayTitle.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 48, color: StiraTokens.stiraMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications.',
                    style: GoogleFonts.dmSans(color: StiraTokens.stiraMuted),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final date = DateTime.tryParse(item['timestamp'] as String? ?? '') ?? DateTime.now();
                final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                final isRead = item['is_read'] == true;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () async {
                      if (!isRead) {
                        // Mark as read in Hive box
                        final userData = Hive.box('user_data');
                        final historyList = List<Map>.from(userData.get('notification_history', defaultValue: []));
                        if (index < historyList.length) {
                          historyList[index]['is_read'] = true;
                          await userData.put('notification_history', historyList);
                          setState(() {});
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isRead ? 0.6 : 1.0,
                      child: StiraGlassCard(
                        accentColor: isRead 
                            ? Colors.white.withValues(alpha: 0.15) 
                            : (item['is_high_risk'] == true ? StiraTokens.stiraPink : StiraTokens.stiraAmber),
                        fullWidth: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  timeStr,
                                  style: StiraTokens.captionMono.copyWith(fontSize: 10),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: StiraTokens.stiraPink,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: StiraTokens.stiraPink.withValues(alpha: 0.6),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['title'] as String? ?? 'Alert',
                              style: GoogleFonts.syne(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: StiraTokens.stiraWhite,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['body'] as String? ?? '',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: StiraTokens.stiraMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

