class UrgeQuote {
  final String title;
  final String body;
  final int minUrge;
  final int maxUrge;

  const UrgeQuote({
    required this.title,
    required this.body,
    required this.minUrge,
    required this.maxUrge,
  });
}

class StiraQuotesDatabase {
  // Urgent states (Urge 8-10): Stop-gap, high alert, physical distraction.
  static const List<UrgeQuote> criticalUrges = [
    UrgeQuote(
      title: "Drop the screen. Right now.",
      body: "An urge peaks in 90 seconds. Go wash your face with cold water or do 10 pushups. Let it pass.",
      minUrge: 8,
      maxUrge: 10,
    ),
    UrgeQuote(
      title: "This is a physical trap.",
      body: "Your brain is demanding a dopamine shortcut. Don't negotiate with the urge. Get up and walk outside.",
      minUrge: 8,
      maxUrge: 10,
    ),
    UrgeQuote(
      title: "Pause. Breathe. Interrupt.",
      body: "Your environment is feeding this urge. Stand up immediately and move to a different room. You can break this loop.",
      minUrge: 8,
      maxUrge: 10,
    )
  ];

  // Elevated states (Urge 5-7): Mindset shifting, reasoning, reminding commitments.
  static const List<UrgeQuote> elevatedUrges = [
    UrgeQuote(
      title: "It's building. Stay conscious.",
      body: "You're entering the window where willpower fails. Open your Rewire Map and check your commitment.",
      minUrge: 5,
      maxUrge: 7,
    ),
    UrgeQuote(
      title: "Choose your future self.",
      body: "The friction you feel right now is the sound of your brain rewiring. Ten minutes of discomfort or hours of regret?",
      minUrge: 5,
      maxUrge: 7,
    ),
    UrgeQuote(
      title: "Urges are like waves.",
      body: "They build, they crest, and they wash away. You don't have to fight the wave — just ride it out for 5 minutes.",
      minUrge: 5,
      maxUrge: 7,
    )
  ];

  // Low/Calm states (Urge 1-4): Anchoring positive habits, general mindfulness.
  static const List<UrgeQuote> calmUrges = [
    UrgeQuote(
      title: "You are in control.",
      body: "A clean day isn't the absence of urges; it's the presence of choosing differently. Keep building.",
      minUrge: 1,
      maxUrge: 4,
    ),
    UrgeQuote(
      title: "Every choice counts.",
      body: "Your current streak is built one simple decision at a time. Enjoy the clarity today.",
      minUrge: 1,
      maxUrge: 4,
    ),
    UrgeQuote(
      title: "Consistency builds freedom.",
      body: "Your brain is forming new neural pathways with every calm hour. Appreciate this steady state.",
      minUrge: 1,
      maxUrge: 4,
    )
  ];

  static UrgeQuote getQuoteForUrge(int urgeLevel) {
    if (urgeLevel >= 8) {
      return (List<UrgeQuote>.from(criticalUrges)..shuffle()).first;
    }
    if (urgeLevel >= 5) {
      return (List<UrgeQuote>.from(elevatedUrges)..shuffle()).first;
    }
    return (List<UrgeQuote>.from(calmUrges)..shuffle()).first;
  }
}
