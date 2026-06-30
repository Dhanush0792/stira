enum RiskLevel { low, moderate, elevated, critical }

class RiskResult {
  final int score;
  final RiskLevel level;

  RiskResult(this.score, this.level);
}

class RiskEngine {
  static RiskResult evaluate({
    required int urge,
    required bool isAlone,
    required int currentHour,
    required int vulnerableWindowStart,
    int? sleepHours,
    bool hasConsecutiveElevated = false,
  }) {
    int adjustment = 0;

    // +1 Vulnerable window
    // (default window spans 4 hours)
    if (currentHour >= vulnerableWindowStart &&
        currentHour < vulnerableWindowStart + 4) {
      adjustment += 1;
    } else if (currentHour >= 22 || currentHour < 6) {
      // General late night vulnerability
      adjustment += 1;
    }

    // +1 Alone
    if (isAlone) {
      adjustment += 1;
    }

    // +1 Sleep < 6
    if (sleepHours != null && sleepHours < 6) {
      adjustment += 1;
    }

    // +1 Consecutive elevated in last 24h
    if (hasConsecutiveElevated) {
      adjustment += 1;
    }

    // Cap total environmental/biological adjustment at +3
    if (adjustment > 3) {
      adjustment = 3;
    }

    // Base urge + adjustments, clamped to 0-10
    int finalScore = (urge + adjustment).clamp(0, 10);

    // Determine level
    RiskLevel level;
    if (finalScore <= 3) {
      level = RiskLevel.low;
    } else if (finalScore <= 6) {
      level = RiskLevel.moderate;
    } else if (finalScore <= 8) {
      level = RiskLevel.elevated;
    } else {
      level = RiskLevel.critical;
    }

    return RiskResult(finalScore, level);
  }
}
