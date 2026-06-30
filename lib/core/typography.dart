import 'package:flutter/material.dart';
import 'theme/earth_night.dart';

/// A clinically grounded typography system designed to reduce arousal, 
/// increase breathing space, and feel emotionally safe. 
/// Avoids urgency, hype, and supports nervous system regulation.
class StiraTypography {
  
  /// 1️⃣ Hero / Primary Title
  /// Used in: Stability headline.
  static const TextStyle hero = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.5,
    color: EarthNight.textPrimary,
  );

  /// 2️⃣ Section Title / Metric Numbers
  /// Used for: Metrics, large numbers, significant data points.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.2,
    color: EarthNight.textPrimary,
  );

  /// 3️⃣ Body Text
  /// Used for: General body.
  static final TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.7,
    color: EarthNight.textPrimary.withValues(alpha: 0.90),
  );

  /// 4️⃣ Card Labels
  /// Used for: Small titles on cards.
  static final TextStyle cardLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: EarthNight.textPrimary.withValues(alpha: 0.9),
  );

  /// 5️⃣ Secondary Information
  /// Used for: Secondary text, timestamps.
  static final TextStyle microText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: EarthNight.textSecondary.withValues(alpha: 0.6), // 60% opacity
  );

  /// 6️⃣ Button Text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: EarthNight.textPrimary,
  );
}
