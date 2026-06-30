import 'package:flutter/material.dart';
import '../../core/theme/earth_night.dart';
import '../../core/common_widgets/stira_widgets.dart';
import '../../services/local_storage.dart';

/// Allows the user to write or edit a short message to themselves.
/// Displayed on dashboard when risk is elevated.
class FutureYouScreen extends StatefulWidget {
  const FutureYouScreen({super.key});

  @override
  State<FutureYouScreen> createState() => _FutureYouScreenState();
}

class _FutureYouScreenState extends State<FutureYouScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = StorageService().futureYouMessage;
    if (existing != null) _controller.text = existing;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    await StorageService().setFutureYouMessage(text);
    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              32,
              24,
              32,
              MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'A message\nto yourself.',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: EarthNight.textPrimary,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'What would you like to remind yourself during difficult moments?',
                  style: TextStyle(
                    color: EarthNight.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                RepaintBoundary(
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    maxLength: 200,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(
                      color: EarthNight.textPrimary,
                      fontSize: 17,
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write calmly. This is for you.',
                      hintStyle: TextStyle(
                        color: EarthNight.textSecondary.withValues(alpha: 0.6),
                        fontSize: 15,
                      ),
                      counterStyle: const TextStyle(
                        color: EarthNight.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _saving
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: EarthNight.accentViolet))
                    : StiraButton(
                        text: 'Save Message',
                        onPressed: _save,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
