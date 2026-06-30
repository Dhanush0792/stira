import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../core/intelligence_layer.dart';

class RewireMapScreen extends StatefulWidget {
  final StabilityState state;

  const RewireMapScreen({super.key, required this.state});

  @override
  State<RewireMapScreen> createState() => _RewireMapScreenState();
}

class _RewireMapScreenState extends State<RewireMapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  String _selectedInfo = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 4),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    // Bug Fix #4: Loop with reverse for a living, breathing animation
    _controller.repeat(reverse: true);
    
    // Set initial text based on days
    _setInitialInfo();
  }
  
  void _setInitialInfo() {
    final streak = widget.state.streak;
    if (streak >= 90) {
      _selectedInfo = '90+ Days: Major structural changes in dopamine receptors. Old pathways are deeply dormant.';
    } else if (streak >= 30) {
      _selectedInfo = '30 Days: Frontal cortex connectivity improving. You are regaining conscious control over impulses.';
    } else if (streak >= 7) {
      _selectedInfo = '7 Days: Initial neuroplasticity begins. New healthy coping pathways are forming.';
    } else {
      _selectedInfo = 'Days 1-6: Surviving the withdrawal phase. Your brain is craving its old baseline.';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Brain is roughly 300x350. Center is 150, 175.
    final dx = localPosition.dx;
    final dy = localPosition.dy;

    setState(() {
      if (dy < 120) {
        // Bug Fix #4: Fix Dart string interpolation (was $widget.state instead of ${widget.state})
        _selectedInfo = 'Prefrontal Cortex: Your executive control center. Currently strengthening through your ${widget.state.totalCheckins} check-ins.';
      } else if (dx < 150 && dy > 120 && dy < 250) {
        _selectedInfo = 'Amygdala: The stress and fear center. Your steady ${widget.state.stabilityIndex}% stability is cooling down its reactivity.';
      } else if (dx >= 150 && dy > 120 && dy < 250) {
        _selectedInfo = 'Ventral Striatum: The reward pathway. Your dopamine sensitivity is recalibrating with every day of your ${widget.state.streak}-day streak.';
      } else {
        _selectedInfo = 'Neural Network: Your brain is a dynamic system. Consistency is the only metric that matters.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 200,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StiraTokens.stiraTeal.withValues(alpha: 0.1),
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
                              color: StiraTokens.stiraWhite.withValues(alpha: 0.05),
                              border: Border.all(color: StiraTokens.stiraWhite.withValues(alpha: 0.1)),
                            ),
                            child: const Icon(Icons.arrow_back, size: 16, color: StiraTokens.stiraWhite),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'The Rewire Map',
                          style: GoogleFonts.syne(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: StiraTokens.stiraWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Clean Days Header
                  Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24),
                     child: Text(
                        'Your dopamine receptors are recovering. This is what that looks like.',
                        style: GoogleFonts.dmSans(
                           fontSize: 14,
                           color: StiraTokens.stiraMuted,
                        ),
                        textAlign: TextAlign.center,
                     ),
                  ),

                  // Bug Fix #4: Show real streak + stability stats
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatChip(
                          label: 'CLEAN DAYS',
                          value: '${widget.state.streak}',
                          color: StiraTokens.stiraTeal,
                        ),
                        _StatChip(
                          label: 'STABILITY',
                          value: '${widget.state.stabilityIndex}%',
                          color: StiraTokens.stiraViolet,
                        ),
                        _StatChip(
                          label: 'CHECK-INS',
                          value: '${widget.state.totalCheckins}',
                          color: StiraTokens.stiraPink,
                        ),
                      ],
                    ),
                  ),

                  // Brain Painter
                  GestureDetector(
                     onTapUp: _handleTap,
                     child: SizedBox(
                        width: 300,
                        height: 350,
                        child: AnimatedBuilder(
                           animation: _animation,
                           builder: (context, child) {
                              return CustomPaint(
                                 painter: _BrainPainter(
                                    progress: _animation.value,
                                    state: widget.state,
                                    cleanDays: widget.state.streak,
                                 ),
                              );
                           },
                        ),
                     ),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Info Card
                  Padding(
                     padding: const EdgeInsets.all(24.0),
                     child: StiraGlassCard(
                        accentColor: StiraTokens.stiraTeal,
                        fullWidth: true,
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Row(
                                 children: [
                                    const Icon(Icons.psychology, color: StiraTokens.stiraTeal, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                       'NEUROPLASTICITY',
                                       style: GoogleFonts.dmMono(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: StiraTokens.stiraTeal,
                                          letterSpacing: 1.2,
                                       ),
                                    ),
                                 ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                 _selectedInfo,
                                 style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    color: StiraTokens.stiraWhite,
                                    height: 1.5,
                                 ),
                              ),
                           ],
                        ),
                     ),
                  ),
                  const SizedBox(height: 16),
                ],
             ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmMono(
              fontSize: 9,
              color: color.withValues(alpha: 0.7),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrainPainter extends CustomPainter {

  final double progress;
  final StabilityState state;
  final int cleanDays;

  _BrainPainter({required this.progress, required this.state, required this.cleanDays});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final streak = state.streak;
    final totalCheckins = state.totalCheckins;
    final stabilityIndex = state.stabilityIndex;
    
    // Config based on progress metrics
    // Legacy pathways fade at 90 days
    double oldPathwayAlpha = max(0.0, 0.35 - (streak / 90.0) * 0.35);
    
    // New pathways density increases with total check-ins (repetition builds pathways)
    // 0-10 checkins = 2 paths, 10-50 = 8 paths, 50+ = up to 20 paths
    int newPathwaysCount = 2;
    if (totalCheckins >= 50) newPathwaysCount = 20;
    else if (totalCheckins >= 25) newPathwaysCount = 12;
    else if (totalCheckins >= 10) newPathwaysCount = 8;
    
    // Base glowing circle (Clarity depends on Stability Index)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
           StiraTokens.stiraTeal.withValues(alpha: (0.1 + (stabilityIndex / 100.0) * 0.2) * progress),
           Colors.transparent,
        ]
      ).createShader(Rect.fromCircle(center: center, radius: 150));
    canvas.drawCircle(center, 130, glowPaint);

    // Draw old pathways (red - impulsive legacy)
    final oldPaint = Paint()
      ..color = StiraTokens.stiraPink.withValues(alpha: oldPathwayAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
      
    _drawPathways(canvas, center, size, oldPaint, 10, pi / 8, 0.85);

    // Draw new pathways (teal/violet - regulated growth)
    if (newPathwaysCount > 0) {
       final newPaint = Paint()
         ..color = (stabilityIndex > 70 ? StiraTokens.stiraTeal : StiraTokens.stiraViolet).withValues(alpha: 0.7 * progress)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2.0 + (streak / 30.0).clamp(0.0, 3.0) // Pathways thicken with streak
         ..strokeCap = StrokeCap.round
         ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0);
         
       _drawPathways(canvas, center, size, newPaint, newPathwaysCount, -pi / 16, progress);
    }
  }
  
  void _drawPathways(Canvas canvas, Offset center, Size size, Paint paint, int count, double angleOffset, double scaleProgress) {
      final random = Random(42); // Deterministic seed
      
      for (int i = 0; i < count; i++) {
         final path = Path();
         
         // Start from base of brain (brainstem area)
         final startX = center.dx + (random.nextDouble() * 20 - 10);
         final startY = center.dy + 80;
         path.moveTo(startX, startY);
         
         double currentX = startX;
         double currentY = startY;
         
         // Build segment by segment
         int segments = 4;
         for (int s = 0; s < segments; s++) {
            // Expand outward and upward
            double targetX = currentX + (random.nextBool() ? 1 : -1) * (20 + random.nextDouble() * 30);
            double targetY = currentY - (30 + random.nextDouble() * 40);
            
            // Constrain points to a rough brain shape
            double angle = atan2(targetY - center.dy, targetX - center.dx);
            double maxDist = 120; // Brain Radius approximation
            
            if (sqrt(pow(targetX - center.dx, 2) + pow(targetY - center.dy, 2)) > maxDist) {
               targetX = center.dx + cos(angle) * maxDist;
               targetY = center.dy + sin(angle) * maxDist;
            }

            // Curve towards target
            double cp1X = currentX + (targetX - currentX) / 2 + (random.nextDouble() * 20 - 10);
            double cp1Y = currentY - 20;
            double cp2X = targetX - (targetX - currentX) / 2 + (random.nextDouble() * 20 - 10);
            double cp2Y = targetY + 20;
            
            // Scale target by progress
            double finalX = currentX + (targetX - currentX) * scaleProgress;
            double finalY = currentY + (targetY - currentY) * scaleProgress;
            
            path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, finalX, finalY);
            
            currentX = targetX;
            currentY = targetY;
         }
         
         canvas.drawPath(path, paint);
      }
  }

  @override
  bool shouldRepaint(covariant _BrainPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.cleanDays != cleanDays || oldDelegate.state != state;
  }
}
