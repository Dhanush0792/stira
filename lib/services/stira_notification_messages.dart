import 'stira_behaviour_reader.dart';

class StiraNotificationMessages {
  static int _getVariantLevel(StiraBehaviourSnapshot snapshot) {
    if (snapshot.daysSinceInstall < 7 || snapshot.peakHourConfidence < 40) return 1; // Generic
    if (snapshot.daysSinceInstall >= 30 && snapshot.peakHourConfidence >= 70) return 3; // Specific
    return 2; // Pattern
  }

  static String _getDayOfWeek() {
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][DateTime.now().weekday - 1];
  }

  static Map<String, String> checkInReminder(StiraBehaviourSnapshot snapshot) {
    final int level = _getVariantLevel(snapshot);
    if (level == 3) {
      return {
        "title": "Check in, ${snapshot.userName}.",
        "body": "${snapshot.topTrigger} hits you hardest around this time. Thirty seconds — just your number.",
        "payload": "/checkin"
      };
    } else if (level == 2) {
      return {
        "title": "Your window is coming.",
        "body": "This time of day tends to be harder for you. One check-in before it builds.",
        "payload": "/checkin"
      };
    }
    return {
      "title": "How are you right now?",
      "body": "Take 30 seconds. Just drag the dial to your number — nothing else needed.",
      "payload": "/checkin"
    };
  }

  static Map<String, String> checkInFollowUp(StiraBehaviourSnapshot snapshot) {
    return {
      "title": "Still with you.",
      "body": "You checked in earlier. Things can shift fast. How are you now?",
      "payload": "/checkin"
    };
  }

  static Map<String, String> vulnerabilityWarning(StiraBehaviourSnapshot snapshot) {
    final int level = _getVariantLevel(snapshot);
    if (level == 3) {
      return {
        "title": "${_getDayOfWeek()} at this time.",
        "body": "Your ${snapshot.topTrigger} pattern is strongest in the next hour. You know this window. Use a tool.",
        "payload": "/tools"
      };
    } else if (level == 2) {
      return {
        "title": "Heads up — your window opens soon.",
        "body": "${snapshot.topTrigger} is your main trigger at this time. Check in now so the system can help.",
        "payload": "/checkin"
      };
    }
    return {
      "title": "Your peak window is approaching.",
      "body": "Based on your pattern, this next hour tends to be your hardest. Stay ahead of it.",
      "payload": "/home"
    };
  }

  static Map<String, String> urgeVelocity(StiraBehaviourSnapshot snapshot) {
    return {
      "title": "Something is building.",
      "body": "Your last few check-ins show things escalating. This is the moment to use a tool — before it peaks.",
      "payload": "/tools"
    };
  }

  static Map<String, String> dangerZone(String zoneName) {
    return {
      "title": "You're near somewhere difficult.",
      "body": "Your pattern shows $zoneName is hard. You don't have to go in. Your tools are one tap away.",
      "payload": "/tools"
    };
  }

  static Map<String, String> safeZone(String zoneName) {
    return {
      "title": "You're in a strong place.",
      "body": "$zoneName is where you do well. Stay as long as you can.",
      "payload": "/home"
    };
  }

  static Map<String, String> streakMilestone(int days, String userName) {
    switch(days) {
      case 3:   return {"title": "Three days.", "body": "Most people stop before this. You didn't. Three days is real.", "payload": "/home"};
      case 7:   return {"title": "One week.", "body": "Seven days. Your brain is already changing. Open your Rewire Map.", "payload": "/home"};
      case 14:  return {"title": "Two weeks.", "body": "Fourteen days of choosing differently. Streak Insurance is now active.", "payload": "/home"};
      case 30:  return {"title": "Thirty days.", "body": "One month. Fewer than 5% of people reach this. You are one of them.", "payload": "/home"};
      case 60:  return {"title": "Sixty days.", "body": "Two months. The old patterns are fading. New ones are your default now.", "payload": "/home"};
      case 90:  return {"title": "90 days.", "body": "Three months. This is when new habits become structural. You did this.", "payload": "/home"};
      case 180: return {"title": "180 days.", "body": "Six months. Your Rewire Map is complete. The old patterns are nearly gone.", "payload": "/home"};
      case 365: return {"title": "One year.", "body": "365 days of choosing yourself. This is identity now, not willpower.", "payload": "/home"};
      default:  return {"title": "Day $days.", "body": "Keep going, $userName. Every day matters.", "payload": "/home"};
    }
  }

  static Map<String, String> preMilestone(int tomorrowMilestone) {
    return {
      "title": "Tomorrow is Day $tomorrowMilestone.",
      "body": "One more day. You've already done the hard part.",
      "payload": "/home"
    };
  }

  static Map<String, String> personalBestApproach(int personalBest, int current) {
    return {
      "title": "One day from your record.",
      "body": "Your personal best is $personalBest days. Tomorrow you tie it. The day after, you break it.",
      "payload": "/home"
    };
  }

  static Map<String, String> relapseSupport(StiraBehaviourSnapshot snapshot) {
    return {
      "title": "Day 1 again. That's okay.",
      "body": "Your total clean days are ${snapshot.totalCleanDays}. A slip doesn't erase what you built. What do you need right now?",
      "payload": "/home"
    };
  }

  static Map<String, String> disengagement48h(StiraBehaviourSnapshot snapshot) {
    return {
      "title": "We haven't heard from you, ${snapshot.userName}.",
      "body": "That's okay. One tap — just your number today. Nothing else needed.",
      "payload": "/checkin"
    };
  }

  static Map<String, String> disengagement72h(StiraBehaviourSnapshot snapshot) {
    return {
      "title": "You went quiet. No judgment.",
      "body": "However the last few days went — Stira doesn't reset your worth. Check in whenever you're ready.",
      "payload": "/home"
    };
  }

  static Map<String, String> dopamineJournal() {
    return {
      "title": "What gave you real dopamine today?",
      "body": "One sentence. It doesn't have to be big. A meal. A conversation. A quiet hour.",
      "payload": "/journal"
    };
  }

  static Map<String, String> identityPush(int dayIndex) {
    final List<String> completions = [
      "...keeps my word to myself.",
      "...chooses long-term over short-term.",
      "...is stronger than my habits.",
      "...builds, not destroys.",
      "...is already changing.",
      "...does not need this.",
      "...has proven they can stop.",
      "...values their future self.",
      "...chooses differently today.",
      "...is becoming someone new.",
    ];
    return {
      "title": "I am someone who...",
      "body": completions[dayIndex % 10],
      "payload": "/identity"
    };
  }

  static Map<String, String> sameTimeTomorrow(String userName, String commitmentText) {
    String text = commitmentText;
    if (text.length > 40) {
      text = "${text.substring(0, 37)}...";
    }
    return {
      "title": "$userName, you said: \"$text\"",
      "body": "It's that time. You planned for this moment. How did it go?",
      "payload": "/checkin"
    };
  }

  static Map<String, String> weeklyReport() {
    return {
      "title": "Your week in review is ready.",
      "body": "Stability trend, top trigger, and one focus for the week ahead.",
      "payload": "/insights"
    };
  }

  static Map<String, String> morningAnchor(StiraBehaviourSnapshot snapshot) {
    return {
      "title": "Good morning, ${snapshot.userName}.",
      "body": "Day ${snapshot.currentStreak + 1} starts now. Your ${snapshot.topTrigger} window is this evening. Plan for it.",
      "payload": "/home"
    };
  }

  static Map<String, String> stabilityImproving(StiraBehaviourSnapshot snapshot) {
    return {
      "title": "Your stability is rising.",
      "body": "Your urges have been lower this week than last week. That number is real. You're building something.",
      "payload": "/insights"
    };
  }
}
