import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stira_tour_controller.dart';
import 'stira_tour_data.dart';
import '../../theme/stira_tokens.dart';

class StiraTourOverlay extends ConsumerWidget {
  const StiraTourOverlay({super.key});

  Color _getAccentColor(String accentName) {
    switch (accentName) {
      case 'pink': return StiraTokens.stiraPink;
      case 'teal': return StiraTokens.stiraTeal;
      case 'amber': return StiraTokens.stiraAmber;
      case 'violet': return StiraTokens.stiraViolet;
      default: return StiraTokens.stiraPink;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(tourControllerProvider);

    if (!controller.isVisible && !controller.isCompleted) {
      // Allow it to transition before totally dropping
      return const SizedBox.shrink();
    }

    final step = controller.currentStep;
    final accentColor = _getAccentColor(step.accentColor);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: controller.isVisible ? 1.0 : 0.0,
      child: Stack(
        children: [
          // Background Dimming
          GestureDetector(
            onTap: () {}, // Do nothing, trap taps
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.60),
            ),
          ),
          
          // The Card
          if (controller.isVisible)
            _AnimatedCardPosition(
              anchor: step.anchor,
              child: _buildCard(context, controller, step, accentColor),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, StiraTourController controller, StiraTourStep step, Color accentColor) {
    final double cardWidth = MediaQuery.of(context).size.width - 32;
    final double actualWidth = cardWidth > 360 ? 360 : cardWidth;

    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(offset.dx, offset.dy * MediaQuery.of(context).size.height),
          child: Material(
            type: MaterialType.transparency,
            child: child,
          ),
        );
      },
      child: Container(
        width: actualWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            // Dynamic Shadow / Glow
            BoxShadow(
              color: accentColor.withValues(alpha: 0.20),
              blurRadius: 32,
              offset: Offset.zero,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${controller.currentStepIndex + 1} of ${controller.totalSteps}",
                        style: GoogleFonts.dmMono(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.50),
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.skipTour(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Skip",
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.60),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // PROGRESS BAR
                  Container(
                    width: double.infinity,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 3,
                        width: (actualWidth - 40) * controller.progress,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ACCENT LINE
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // TITLE
                  Text(
                    step.title,
                    style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // DESCRIPTION
                  Text(
                    step.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // NAVIGATION ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left (Back)
                      controller.currentStepIndex > 0
                          ? GestureDetector(
                              onTap: () => controller.previousStep(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.08),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.20),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.70),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),

                      // Right (Next / Finish)
                      controller.currentStepIndex < controller.totalSteps - 1
                          ? GestureDetector(
                              onTap: () => controller.nextStep(),
                              child: Row(
                                children: [
                                  Text(
                                    "Next",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: accentColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentColor.withValues(alpha: 0.40),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: () => controller.completeTour(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Get Started",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCardPosition extends StatelessWidget {
  final TourAnchor anchor;
  final Widget child;

  const _AnimatedCardPosition({required this.anchor, required this.child});

  @override
  Widget build(BuildContext context) {
    if (anchor == TourAnchor.center) {
      return Center(child: child);
    }
    
    final safeAreaTop = MediaQuery.of(context).padding.top;
    
    // Position elements
    double? top;
    double? bottom;
    double? left;
    double? right;

    switch (anchor) {
      case TourAnchor.topCenter:
        top = safeAreaTop + 80;
        left = 0; right = 0;
        break;
      case TourAnchor.bottomCenter:
        bottom = 120;
        left = 0; right = 0;
        break;
      case TourAnchor.bottomLeft:
        bottom = 120;
        left = 16;
        break;
      case TourAnchor.bottomRight:
        bottom = 120;
        right = 16;
        break;
      default:
        break;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: anchor == TourAnchor.topCenter || anchor == TourAnchor.bottomCenter
          ? Align(alignment: Alignment.center, child: child)
          : child,
    );
  }
}
