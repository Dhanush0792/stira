enum RiskLevel {
  low,
  moderate,
  elevated,
  critical
}

class RiskResult {
  final int riskScore;
  final RiskLevel riskLevel;

  const RiskResult({
    required this.riskScore,
    required this.riskLevel,
  });
}

class RiskEngine {
  /// Evaluates the real-time vulnerability level.
  /// Modifiers cap at +4.
  static RiskResult evaluate({
    required int urgeLevel,
    required bool alone,
    required int energyLevel,
    required int sleepHours,
    required DateTime currentTime,
    required bool highRiskWindowMatch,
    required bool isolationAmplifier,
    required bool relapseWithin72h,
    required int elevatedEventsLast24h,
  }) {
    int score = urgeLevel;
    int modifiers = 0;

    if (alone || isolationAmplifier) modifiers += 1;
    if (highRiskWindowMatch) modifiers += 1;
    if (energyLevel <= 2) modifiers += 1;
    if (sleepHours >= 0 && sleepHours < 6) modifiers += 1;
    if (elevatedEventsLast24h >= 2) modifiers += 1;
    if (relapseWithin72h) modifiers += 2;

    // Cap modifiers at +4
    if (modifiers > 4) modifiers = 4;

    score += modifiers;

    // Clamp score 0-10
    if (score < 0) score = 0;
    if (score > 10) score = 10;

    RiskLevel level;
    if (score <= 3) {
      level = RiskLevel.low;
    } else if (score <= 6) {
      level = RiskLevel.moderate;
    } else if (score <= 8) {
      level = RiskLevel.elevated;
    } else {
      level = RiskLevel.critical;
    }

    return RiskResult(riskScore: score, riskLevel: level);
  }
}
