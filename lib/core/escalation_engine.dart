// No imports needed for static int logic

class EscalationEngine {
  static int evaluate({
    required int riskScore,
    required bool alone,
    required bool nearForecastWindow,
    required bool relapseWithin72h,
    required int elevatedEventsLast24h,
    required bool isolationAmplifier,
  }) {
    // Level 4 — Containment Mode
    if (riskScore >= 9 || (relapseWithin72h && elevatedEventsLast24h >= 2)) {
      return 4;
    }

    // Level 3 — Environmental Shift
    if ((riskScore >= 7 && (alone || isolationAmplifier)) ||
        (nearForecastWindow && riskScore >= 6)) {
      return 3;
    }

    // Level 2 — Structured Pause
    if (riskScore >= 7 || elevatedEventsLast24h >= 2) {
      return 2;
    }

    // Level 1 — Rising
    if (riskScore >= 4 || elevatedEventsLast24h >= 1 || nearForecastWindow) {
      return 1;
    }

    // Level 0 — Stable
    return 0;
  }
}
