import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/stira_tokens.dart';

/// StiraDestructiveText — For Reset ONLY. Always shows confirmation dialog.
/// Props: label, onTap (only fires after confirmation)
class StiraDestructiveText extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const StiraDestructiveText({
    super.key,
    required this.label,
    required this.onTap,
  });

  Future<void> _handleTap(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StiraTokens.stiraBg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: StiraTokens.stiraGlassBorder),
        ),
        title: Text(
          'Reset your streak?',
          style: GoogleFonts.syne(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: StiraTokens.stiraWhite,
          ),
        ),
        content: Text(
          'This cannot be undone.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: StiraTokens.stiraMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: StiraTokens.stiraMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Reset',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: StiraTokens.stiraPink,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _handleTap(context),
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: StiraTokens.stiraPink.withValues(alpha: 0.70),
        ),
      ),
    );
  }
}
