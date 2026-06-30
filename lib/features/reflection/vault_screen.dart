import 'package:flutter/material.dart';
import '../../core/theme/earth_night.dart';
import '../../core/common_widgets/stira_widgets.dart';
import '../../services/local_storage.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  late List<String> _fragments;
  late bool _canOpen;

  @override
  void initState() {
    super.initState();
    final storage = StorageService();
    _fragments = storage.getVaultFragments();
    
    // Vault opens if: It's Sunday OR streak is >= 7 days.
    final now = DateTime.now();
    final streak = storage.calculateStreak();
    _canOpen = now.weekday == DateTime.sunday || streak >= 7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EarthNight.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EarthNight.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'The Vault',
          style: TextStyle(
            color: EarthNight.textSecondary,
            fontSize: 16,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Memory\nFragments.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: EarthNight.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Fragments are deposited when you successfully navigate a high urge using The Pause. The Vault opens on Sundays or after 7 steady days.',
                style: TextStyle(
                  color: EarthNight.textSecondary.withValues(alpha: 0.8),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              if (_fragments.isEmpty) ...[
                const Expanded(
                  child: Center(
                    child: Text(
                      'The Vault is empty.',
                      style: TextStyle(color: EarthNight.textSecondary),
                    ),
                  ),
                )
              ] else if (!_canOpen) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: EarthNight.textSecondary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_fragments.length} fragments secured.\nVault opens on Sunday.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: EarthNight.textSecondary.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ] else ...[
                Expanded(
                  child: ListView.builder(
                    itemCount: _fragments.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SanctuaryCard(
                          child: Text(
                            _fragments[index],
                            style: const TextStyle(
                              color: EarthNight.textPrimary,
                              fontSize: 16,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
