import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_card_label.dart';
import '../../services/stira_auth_service.dart';
import '../../services/stira_vault_service.dart';
import 'vault_composer_screen.dart';
import 'vault_letter_screen.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = StiraAuthService().getCurrentUser();
    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Radial gradient at top-center
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StiraTokens.stiraAmber.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StiraTokens.stiraWhite.withOpacity(0.05),
                            border: Border.all(color: StiraTokens.stiraWhite.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.arrow_back, size: 16, color: StiraTokens.stiraWhite),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'The Vault',
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: StiraTokens.stiraWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: StiraVaultService().vaultLettersStream(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: StiraTokens.stiraAmber));
                      }
                      
                      final docs = snapshot.data?.docs ?? [];
                      
                      if (docs.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 80),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return _buildLetterCard(context, data);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VaultComposerScreen()),
        ),
        backgroundColor: StiraTokens.stiraAmber,
        child: const Icon(Icons.vpn_key, color: StiraTokens.stiraBg),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StiraTokens.stiraAmber.withOpacity(0.1),
              ),
              child: const Icon(Icons.vpn_key, size: 32, color: StiraTokens.stiraAmber),
            ),
            const SizedBox(height: 24),
            Text(
              'Write to your future self.',
              textAlign: TextAlign.center,
              style: GoogleFonts.syne(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: StiraTokens.stiraWhite,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When the urge is strong, Stira will open this — and you will read your own words from a place of strength.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: StiraTokens.stiraMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VaultComposerScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: StiraTokens.stiraAmber,
                foregroundColor: StiraTokens.stiraBg,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Write Your First Letter',
                style: GoogleFonts.syne(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterCard(BuildContext context, Map<String, dynamic> data) {
    final timestamp = data['created_at'] as Timestamp?;
    final dateStr = timestamp != null 
        ? DateFormat('MMM d, yyyy').format(timestamp.toDate())
        : '';
    final tag = data['emotional_tag'] ?? 'Feeling Strong';
    final content = data['content'] ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VaultLetterScreen(letterData: data),
        ),
      ),
      child: StiraGlassCard(
        accentColor: StiraTokens.stiraAmber,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: StiraTokens.stiraAmber.withOpacity(0.1),
                    border: Border.all(color: StiraTokens.stiraAmber.withOpacity(0.3)),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: StiraTokens.stiraAmber,
                    ),
                  ),
                ),
                Text(
                  dateStr.toUpperCase(),
                  style: GoogleFonts.dmMono(
                    fontSize: 9,
                    color: StiraTokens.stiraMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: StiraTokens.stiraMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
