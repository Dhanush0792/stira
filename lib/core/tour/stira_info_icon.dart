import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stira_tour_data.dart';
import '../../theme/stira_tokens.dart';

class StiraInfoIcon extends StatelessWidget {
  final String featureId;
  final double size;
  final Color? color;

  const StiraInfoIcon({
    required this.featureId,
    this.size = 18.0,
    this.color,
    super.key,
  });

  Color _getAccentColor(String accentName) {
    switch (accentName) {
      case 'pink': return StiraTokens.stiraPink;
      case 'teal': return StiraTokens.stiraTeal;
      case 'amber': return StiraTokens.stiraAmber;
      case 'violet': return StiraTokens.stiraViolet;
      default: return StiraTokens.stiraPink;
    }
  }

  void _showInfoSheet(BuildContext context, String featureId) {
    final info = StiraTourData.featureInfoMap[featureId];
    if (info == null) return;

    final accentColor = _getAccentColor(info.accentColor);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: StiraTokens.stiraBg2,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: -10,
                  )
                ],
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DRAG HANDLE
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        
                        // ACCENT BADGE ROW
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  info.title,
                                  style: GoogleFonts.syne(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // SUBTITLE
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                          child: Text(
                            info.subtitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ),

                        // DIVIDER
                        Container(
                          width: double.infinity,
                          height: 1,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          color: Colors.white.withValues(alpha: 0.08),
                        ),

                        // BODY TEXT
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            info.body,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withValues(alpha: 0.80),
                              height: 1.65,
                            ),
                          ),
                        ),

                        // TIP BOX
                        if (info.tip != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.lightbulb_outline, size: 14, color: accentColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      info.tip!,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: accentColor.withValues(alpha: 0.90),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                        // BOTTOM PADDING
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfoSheet(context, featureId),
      child: Container(
        width: size + 8,
        height: size + 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1),
        ),
        child: Center(
          child: Icon(
            Icons.info_outline,
            size: size,
            color: color ?? Colors.white.withValues(alpha: 0.40),
          ),
        ),
      ),
    );
  }
}
