import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/stira_bond_service.dart';
import 'bond_setup_screen.dart';
import 'bond_active_screen.dart';
import '../../theme/stira_tokens.dart';

class BondModeScreen extends ConsumerWidget {
  const BondModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bondAsync = ref.watch(bondStatusProvider);

    return bondAsync.when(
      data: (data) {
        final partnerUid = data?['bond_partner_uid'] as String?;
        if (partnerUid != null && partnerUid.isNotEmpty) {
          return BondActiveScreen(partnerUid: partnerUid, userData: data!);
        } else {
          return const BondSetupScreen();
        }
      },
      loading: () => const Scaffold(
        backgroundColor: StiraTokens.stiraBg,
        body: Center(child: CircularProgressIndicator(color: StiraTokens.stiraViolet)),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: StiraTokens.stiraBg,
        body: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
