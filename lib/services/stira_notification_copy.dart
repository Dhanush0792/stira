import 'stira_behaviour_analyser.dart';

class NotificationContent {
  final String title;
  final String body;
  final String payload; // deep link route
  const NotificationContent(this.title, this.body, this.payload);
}

class StiraNotificationCopy {
  // ─── CHECK-IN REMINDER ───
  static NotificationContent checkInReminder(BehaviourSnapshot s) {
    if (s.daysSinceInstall < 7 || s.peakHourConfidence < 40) {
      return const NotificationContent('How are you doing?',
          'Quick 30-second check-in. Just your number right now.', '/checkin');
    }
    if (s.peakHourConfidence >= 70) {
      return const NotificationContent('Your window is coming.',
          'Based on your pattern, this hour tends to be difficult. One check-in — just drag the dial.', '/checkin');
    }
    return NotificationContent('How are you right now, ${s.userName}?',
        'Your ${s.topTrigger.toLowerCase()} pattern is strongest around this time. Quick check-in.', '/checkin');
  }

  // ─── POST CHECK-IN FOLLOW-UP ("check in again" after engagement) ───
  static NotificationContent postCheckInFollowUp(BehaviourSnapshot s, int hoursAfter) {
    if (hoursAfter <= 4) {
      return NotificationContent('Still with you.',
          'You checked in ${hoursAfter}h ago. Things can shift fast. How are you now?', '/checkin');
    }
    return const NotificationContent('Check in again?',
        'It\'s been a few hours since your last check-in. Your stability score updates with each one.', '/checkin');
  }

  // ─── VULNERABILITY WARNING (predictive) ───
  static NotificationContent vulnerabilityWarning(BehaviourSnapshot s) {
    final hour = s.peakHour;
    final timeStr = _formatHour(hour);

    if (s.peakHourConfidence >= 80 && s.daysSinceInstall >= 30) {
      return NotificationContent('Your window opens in 30 minutes.',
          '${_dayName()} at $timeStr. ${s.topTrigger} hit you here last week. What\'s your plan?', '/home');
    }
    if (s.peakHourConfidence >= 60) {
      return NotificationContent('Your peak window is coming.',
          'Around $timeStr tends to be your hardest hour. Stay ahead of it.', '/home');
    }
    return const NotificationContent('Stay sharp.',
        'Your vulnerable window is approaching. One check-in before it peaks.', '/checkin');
  }

  // ─── URGE VELOCITY (rising check-ins) ───
  static NotificationContent urgeVelocity(BehaviourSnapshot s) {
    return NotificationContent('Something is building.',
        'Your last ${s.checkedInToday ? "check-ins show" : "few hours show"} things escalating. This is the time to use a tool — before it peaks.', '/tools');
  }

  // ─── DISENGAGEMENT — 48 hours ───
  static NotificationContent disengagement48h(BehaviourSnapshot s) {
    return NotificationContent('We haven\'t heard from you, ${s.userName}.',
        'That\'s okay. One tap — just your number today. Nothing else needed.', '/checkin');
  }

  // ─── DISENGAGEMENT — 72 hours ───
  static NotificationContent disengagement72h(BehaviourSnapshot s) {
    return NotificationContent('You went quiet. No judgment.',
        'However the last few days went — Stira doesn\'t reset your worth. Check in whenever you\'re ready.', '/home');
  }

  // ─── DANGER ZONE ───
  static NotificationContent dangerZone(String zoneName) {
    return NotificationContent('You\'re near somewhere difficult.',
        'Your pattern shows $zoneName is hard. You don\'t have to go in. Your tools are one tap away.', '/tools');
  }

  // ─── SAFE ZONE ───
  static NotificationContent safeZone(String zoneName) {
    return NotificationContent('You\'re in a strong place.',
        '$zoneName is where you do well. Stay as long as you can.', '/home');
  }

  // ─── STREAK MILESTONE ───
  static NotificationContent streakMilestone(int days, String userName) {
    final Map<int, List<String>> copy = {
      3:   ['Three days.', 'Most people stop before this point. You didn\'t. Three days is real.'],
      7:   ['One week. Your first new pathway.', 'Seven days. Your brain is already changing. Open your Rewire Map.'],
      14:  ['Two weeks. Streak Insurance unlocked.', 'Fourteen days of choosing differently. Your protection is now active.'],
      30:  ['Thirty days. This is rare.', 'One month. Fewer than 5% of people reach this. You are one of them.'],
      60:  ['Sixty days. The pattern is shifting.', 'Two months. The old pathways are fading. New ones are your default now.'],
      90:  ['90 days. You rewired it.', 'Three months. This is when new habits become structural. You did this.'],
      180: ['180 days. Half a year.', 'Six months. Your Rewire Map is complete. The old patterns are nearly gone.'],
      365: ['One year. You built something real.', '365 days of choosing yourself. This is identity now, not willpower.'],
    };

    final entry = copy[days];
    if (entry != null) return NotificationContent(entry[0], entry[1], '/home');
    return NotificationContent('Day $days.', 'Keep going, $userName. Every day counts.', '/home');
  }

  // ─── PRE-MILESTONE (1 day before) ───
  static NotificationContent preMilestone(int tomorrowMilestone) {
    return NotificationContent('Tomorrow is Day $tomorrowMilestone.',
        'One more day and you hit a milestone. You\'ve already done the hard part.', '/home');
  }

  // ─── PERSONAL BEST APPROACH ───
  static NotificationContent personalBestApproach(int personalBest, int current) {
    return NotificationContent('One day from your record.',
        'Your best ever was $personalBest days. Tomorrow you tie it. The day after, you break it.', '/home');
  }

  // ─── POST RELAPSE SUPPORT ───
  static NotificationContent postRelapse(BehaviourSnapshot s) {
    return NotificationContent('Day 1 again. That\'s okay.',
        'Your total clean days are ${s.totalCleanDays}. A slip doesn\'t erase what you built. What do you need right now?', '/home');
  }

  // ─── DOPAMINE JOURNAL ───
  static NotificationContent dopamineJournal() {
    return const NotificationContent('What gave you real dopamine today?',
        'One sentence. It doesn\'t have to be big. A meal, a conversation, a quiet hour.', '/journal');
  }

  // ─── IDENTITY PUSH ───
  static NotificationContent identityPush(int dayIndex) {
    const completions = [
      'keeps my word to myself.',
      'chooses long-term over short-term.',
      'is stronger than my habits.',
      'builds, not destroys.',
      'is already changing.',
      'does not need this.',
      'has proven they can stop.',
      'values their future self.',
      'chooses differently today.',
      'is becoming someone new.',
    ];
    final completion = completions[dayIndex % completions.length];
    return NotificationContent('I am someone who...',
        '...$completion', '/identity');
  }

  // ─── SAME TIME TOMORROW ───
  static NotificationContent sameTimeTomorrow(String commitment, String userName) {
    final truncated = commitment.length > 40 ? '${commitment.substring(0, 40)}...' : commitment;
    return NotificationContent('$userName, you said: "$truncated"',
        "It's that time. You planned for this moment. How did it go?", '/checkin?source=commitment');
  }

  // ─── WEEKLY REPORT ───
  static NotificationContent weeklyReport() {
    return const NotificationContent('Your week in review is ready.',
        'Your stability trend, top trigger, and one focus for the week ahead.', '/insights/weekly');
  }

  // ─── MORNING ANCHOR ───
  static NotificationContent morningAnchor(BehaviourSnapshot s) {
    return NotificationContent('Good morning, ${s.userName}.',
        'Day ${s.currentStreak + 1} starts now. Your ${s.topTrigger.toLowerCase()} window is at ${_formatHour(s.peakHour)}. Plan for it.', '/home');
  }

  static String _dayName() {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[DateTime.now().weekday % 7];
  }

  static String _formatHour(int hour) {
    if (hour == 0) return 'midnight';
    if (hour == 12) return 'noon';
    if (hour < 12) return '${hour} AM';
    return '${hour - 12} PM';
  }
}
