class NotificationState {
  int sentToday;
  DateTime lastSentAt;
  int consecutiveUntapped;
  bool restMode;
  DateTime? restModeUntil;
  String quietStart; // e.g. "22:30"
  String quietEnd; // e.g. "08:00"
  bool crisisActive;
  DateTime lastResetAt;
  List<int> last3Urges;
  int motivationIndex;
  
  // Phase 1 Expansion: Principled State Discovery
  String behaviorMode; // neutralSupport, attentiveRegulation, protectiveContainment
  int escalationLevel;
  DateTime? lastActionAt;
  bool isGhostMode;

  NotificationState({
    this.sentToday = 0,
    required this.lastSentAt,
    this.consecutiveUntapped = 0,
    this.restMode = false,
    this.restModeUntil,
    this.quietStart = "22:30",
    this.quietEnd = "08:00",
    this.crisisActive = false,
    required this.lastResetAt,
    this.last3Urges = const [],
    this.motivationIndex = 0,
    this.behaviorMode = 'neutralSupport',
    this.escalationLevel = 0,
    this.lastActionAt,
    this.isGhostMode = false,
  });

  Map<String, dynamic> toJson() => {
    'sentToday': sentToday,
    'lastSentAt': lastSentAt.toIso8601String(),
    'consecutiveUntapped': consecutiveUntapped,
    'restMode': restMode,
    'restModeUntil': restModeUntil?.toIso8601String(),
    'quietStart': quietStart,
    'quietEnd': quietEnd,
    'crisisActive': crisisActive,
    'lastResetAt': lastResetAt.toIso8601String(),
    'last3Urges': last3Urges,
    'motivationIndex': motivationIndex,
    'behaviorMode': behaviorMode,
    'escalationLevel': escalationLevel,
    'lastActionAt': lastActionAt?.toIso8601String(),
    'isGhostMode': isGhostMode,
  };

  factory NotificationState.fromJson(Map<String, dynamic> json) => NotificationState(
    sentToday: json['sentToday'],
    lastSentAt: DateTime.parse(json['lastSentAt']),
    consecutiveUntapped: json['consecutiveUntapped'],
    restMode: json['restMode'],
    restModeUntil: json['restModeUntil'] != null ? DateTime.parse(json['restModeUntil']) : null,
    quietStart: json['quietStart'],
    quietEnd: json['quietEnd'],
    crisisActive: json['crisisActive'],
    lastResetAt: DateTime.parse(json['lastResetAt']),
    last3Urges: List<int>.from(json['last3Urges'] ?? []),
    motivationIndex: json['motivationIndex'] ?? 0,
    behaviorMode: json['behaviorMode'] ?? 'neutralSupport',
    escalationLevel: json['escalationLevel'] ?? 0,
    lastActionAt: json['lastActionAt'] != null ? DateTime.parse(json['lastActionAt']) : null,
    isGhostMode: json['isGhostMode'] ?? false,
  );

  factory NotificationState.initial() {
    final now = DateTime.now();
    return NotificationState(
      lastSentAt: now.subtract(const Duration(hours: 4)), // Allow immediate send
      lastResetAt: now,
    );
  }

  void checkReset() {
    final now = DateTime.now();
    if (now.day != lastResetAt.day || now.month != lastResetAt.month || now.year != lastResetAt.year) {
      sentToday = 0;
      lastResetAt = now;
      crisisActive = false; // Reset crisis mode daily
    }
    
    if (restMode && restModeUntil != null && now.isAfter(restModeUntil!)) {
      restMode = false;
      restModeUntil = null;
    }
  }

  bool canSend(bool isCrisis) {
    checkReset();
    final now = DateTime.now();
    
    // Rule 1: HARD DAILY LIMIT
    final limit = restMode ? 1 : (isCrisis || crisisActive ? 4 : 2);
    
    // Rule 1.5: Failsafe Reset (If no notification sent for 24h, we must be unstuck)
    if (sentToday >= limit && now.difference(lastSentAt).inHours >= 24) {
      sentToday = 0;
      lastResetAt = now;
    }

    if (sentToday >= limit) return false;

    // Rule 2: QUIET HOURS
    if (_isInQuietHours(now)) return false;

    // Rule 3: MINIMUM GAP (3 hours)
    if (now.difference(lastSentAt).inHours < 3) return false;

    return true;
  }

  bool _isInQuietHours(DateTime now) {
    final startParts = quietStart.split(':');
    final endParts = quietEnd.split(':');
    
    final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
    final endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));

    if (startTime.isBefore(endTime)) {
      // Quiet hours do not cross midnight (e.g. 08:00 - 10:00) - unusual but possible
      return now.isAfter(startTime) && now.isBefore(endTime);
    } else {
      // Quiet hours cross midnight (e.g. 22:30 - 08:00)
      return now.isAfter(startTime) || now.isBefore(endTime);
    }
  }

  void markSent() {
    sentToday++;
    lastSentAt = DateTime.now();
  }

  void recordTap() {
    consecutiveUntapped = 0;
    if (restMode) {
       restMode = false;
       restModeUntil = null;
    }
  }

  void recordMiss() {
    consecutiveUntapped++;
    if (consecutiveUntapped >= 5) {
      restMode = true;
      // Relaxed to 2 days instead of 7 to avoid long silences
      restModeUntil = DateTime.now().add(const Duration(days: 2));
    }
  }

  void resetMiss() {
    consecutiveUntapped = 0;
    restMode = false;
    restModeUntil = null;
  }
}
