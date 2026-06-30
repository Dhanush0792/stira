import 'package:flutter/material.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../services/local_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                    'No alerts yet.',
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
                final date = DateTime.parse(item['timestamp'] as String);
                final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StiraGlassCard(
                    accentColor: item['is_high_risk'] == true ? StiraTokens.stiraPink : StiraTokens.stiraAmber,
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
                            if (item['is_read'] == false)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: StiraTokens.stiraPink,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.syne(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: StiraTokens.stiraWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['body'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: StiraTokens.stiraMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
