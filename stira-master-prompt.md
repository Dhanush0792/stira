# STIRA — MASTER REDESIGN PROMPT FOR ANTIGRAVITY
# Read every word. Do not skip sections. Do not make assumptions.

---

## 🧠 STEP 0 — READ THE CODEBASE FIRST

Before writing a single line of code:
1. Open every file in the project
2. Read every widget, every screen, every route
3. Map out: which file = which screen
4. Understand the current state management (Provider / Riverpod / Bloc / setState — identify which one is used)
5. Do NOT rename files, do NOT change routing logic, do NOT change data models
6. You are ONLY changing visual/UI code — colors, widgets, layouts, animations, typography

Only after fully reading and understanding the code, begin implementing changes screen by screen.

---

## 🎯 WHAT THIS APP IS

**App name:** Stira
**Purpose:** A behavioral analysis and pornography reduction app
**Platform:** Flutter (Android + iOS)
**Goal of this prompt:** Redesign every screen visually to match a premium dark glassmorphism aesthetic — like the Veri health app by @rondesignlab — without breaking any existing logic, navigation, or data.

---

## 🎨 DESIGN SYSTEM — IMPLEMENT THESE FIRST (before touching any screen)

Create a file called `lib/theme/stira_theme.dart` and define ALL of the following. Every screen must import and use this file. Never hardcode a color or font anywhere else.

### Color Palette
```dart
// Background
static const Color bgDeep = Color(0xFF07060F);
static const Color bgCard = Color(0xFF0D0B1A);

// Accent colors (one per card context)
static const Color pink = Color(0xFFE8307A);
static const Color teal = Color(0xFF1ECFB3);
static const Color amber = Color(0xFFF5A623);
static const Color violet = Color(0xFF7C4DFF);

// Glass / UI
static const Color glassWhite = Color(0x0EFFFFFF);       // 5.5% white
static const Color glassBorder = Color(0x17FFFFFF);      // 9% white
static const Color textPrimary = Color(0xFFF0EEF8);
static const Color textMuted = Color(0x73F0EEF8);        // 45% white

// Accent soft fills (for card backgrounds)
static const Color pinkSoft = Color(0x2DE8307A);
static const Color tealSoft = Color(0x261ECFB3);
static const Color amberSoft = Color(0x26F5A623);
static const Color violetSoft = Color(0x267C4DFF);
```

### Typography
```dart
// Use Google Fonts — add to pubspec.yaml if not already present:
// google_fonts: ^6.1.0

// Display / headings → Syne (weight 800, 700)
// Metrics / numbers / labels → DM Mono (weight 500, 400)
// Body / descriptions → DM Sans (weight 400, 300)

static TextStyle displayHero = GoogleFonts.syne(
  fontSize: 32, fontWeight: FontWeight.w800,
  color: StiraTheme.textPrimary, height: 1.1,
);
static TextStyle displayTitle = GoogleFonts.syne(
  fontSize: 20, fontWeight: FontWeight.w700,
  color: StiraTheme.textPrimary,
);
static TextStyle metricLED = GoogleFonts.dmMono(
  fontSize: 32, fontWeight: FontWeight.w500,
  color: StiraTheme.pink, letterSpacing: 1.5,
  shadows: [Shadow(color: StiraTheme.pink, blurRadius: 12)],
);
static TextStyle labelMono = GoogleFonts.dmMono(
  fontSize: 10, fontWeight: FontWeight.w400,
  color: StiraTheme.textMuted, letterSpacing: 2.5,
);
static TextStyle bodyText = GoogleFonts.dmSans(
  fontSize: 13, fontWeight: FontWeight.w400,
  color: StiraTheme.textMuted, height: 1.6,
);
```

### Reusable Glass Card Widget
Create `lib/widgets/glass_card.dart`:
```dart
// A widget that accepts: child, accentColor, width, height, borderRadius
// Renders:
//   - Container with BackdropFilter (ImageFilter.blur sigmaX:16, sigmaY:16)
//   - Background: gradient from accentColor.withOpacity(0.18) to accentColor.withOpacity(0.04)
//   - Border: Border.all(color: accentColor.withOpacity(0.22), width: 1.2)
//   - BorderRadius: BorderRadius.circular(20) by default
//   - ClipRRect wrapping everything
// This widget is used on EVERY screen for every card.
```

### LED Metric Widget
Create `lib/widgets/led_metric.dart`:
```dart
// Accepts: value (String), unit (String), accentColor (Color)
// Renders:
//   - value in DM Mono 32px with color = accentColor
//   - Text shadow: Shadow(color: accentColor, blurRadius: 14)
//   - unit in DM Mono 12px with color = accentColor.withOpacity(0.6)
```

---

## 📱 SCREEN-BY-SCREEN REDESIGN INSTRUCTIONS

### SCREEN 1 — SPLASH SCREEN
**File:** Find the splash/loading screen file (likely `splash_screen.dart` or similar)

**Current state:** Purple glowing orb on black background, "stira" text below

**What to change:**
- Background: `bgDeep` (#07060F) with a radial gradient overlay: `RadialGradient(center: Alignment(0, 0.3), radius: 1.2, colors: [Color(0x40E8307A), Colors.transparent])`
- The orb: Keep it, but use `AnimatedContainer` with:
  - Size: 120x120
  - Decoration: `BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFFE8307A), Color(0xFF7C4DFF), Colors.transparent], stops: [0.0, 0.55, 1.0], center: Alignment(-0.2, -0.2)))`
  - BoxShadow: `[BoxShadow(color: Color(0x80E8307A), blurRadius: 60, spreadRadius: 10), BoxShadow(color: Color(0x33E8307A), blurRadius: 120)]`
  - Animate: scale oscillate 1.0 to 1.06 to 1.0 with 3s duration, repeat forever
- App name: Syne font, 34px, weight 800, color white, letter-spacing -0.5
- Tagline: DM Mono, 10px, letter-spacing 3, uppercase, color textMuted
- Remove any loading indicator — just the orb, name, tagline

---

### SCREEN 2 — ONBOARDING (all steps)
**File:** Find onboarding screen(s) — may be multiple pages or a PageView

**Current state:** Dark screen, question text, pill buttons, Next button

**What to change:**

**Background:**
- Scaffold backgroundColor: `bgDeep`
- Add a subtle radial glow at top: `Container` with `DecoratedBox` using `RadialGradient(center: Alignment(0, -1), colors: [Color(0x25E8307A), Colors.transparent])`

**Progress bar (top):**
- Replace dots with: a `Row` of 5 `AnimatedContainer` widgets
- Each is height 3, borderRadius 2
- Done steps: width 24, color `pink`
- Active step: width 32, color `textPrimary`
- Upcoming steps: width 16, color `glassBorder`
- Gap between each: 5px

**Question text:**
- Font: Syne, 24px, weight 700, color textPrimary, lineHeight 1.2
- Subtitle: DM Sans, 13px, textMuted

**Options (selection buttons):**
- Each option: `GlassCard` widget (accent: pink) with padding 14x18
- Inside: `Row` with a circle indicator + emoji + text
- Unselected: border `glassBorder`, background `glassWhite`
- Selected: border `pink.withOpacity(0.5)`, background `pinkSoft`, circle filled with `pink` + glow shadow
- Add `AnimatedContainer` for smooth selection transition (200ms)

**Next/Continue button:**
- Full width, height 52, borderRadius 16
- Background: `LinearGradient(colors: [pink, Color(0xFFC0246A)])`
- BoxShadow: `BoxShadow(color: Color(0x59E8307A), blurRadius: 30, offset: Offset(0,8))`
- Text: Syne, 15px, weight 700, white

---

### SCREEN 3 — ACCOUNT CREATION / SIGN UP
**File:** Find auth/signup screen

**Current state:** "Create your account" title, email + password fields, Create Account button. CRITICAL BUG: keyboard covers the button.

**What to change:**

**Fix the keyboard bug FIRST:**
```dart
// In the Scaffold:
resizeToAvoidBottomInset: true,
// Wrap content in SingleChildScrollView
// OR use Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
```

**Background:** Same as onboarding — `bgDeep` + pink radial glow top

**Title:** Syne 28px weight 800 "Create your account."
**Subtitle:** DM Sans 13px textMuted "Your data stays on your device." + a small info icon that shows a tooltip

**Text fields:**
- Use `TextFormField` with `InputDecoration`:
  - `filled: true`
  - `fillColor: glassWhite`
  - `border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: glassBorder, width: 1.2))`
  - `focusedBorder`: same but `borderSide: BorderSide(color: pink, width: 1.5)`
  - `labelStyle`: DM Sans, textMuted
  - `contentPadding`: EdgeInsets.symmetric(horizontal: 18, vertical: 16)

**Add social login above the Create Account button:**
```
— or continue with —
[Google button]  [Apple button]
```
- Each social button: GlassCard, row with logo + text, no fill, glassBorder border

**Create Account button:** Same as Continue button above (pink gradient + glow)

---

### SCREEN 4 — DASHBOARD (HOME) — MOST IMPORTANT SCREEN
**File:** Home screen file

**Current state:** Title text at top, orange orb in middle, Forecast card (with lock icon), Behavioral Driver card, Check-in / Pause / Reset buttons, bottom nav

**COMPLETE REDESIGN — follow exactly:**

**Scaffold:**
- `backgroundColor: bgDeep`
- No AppBar — custom top section

**Background ambient glow:**
- Stack at bottom: `Container` with `DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0, -0.5), radius: 1.5, colors: [Color(0x1FF5A623), Colors.transparent])))` — amber glow behind orb

**Top bar (replace AppBar):**
```
Row:
  Left: Column(
    "Good [time], [name]."  Syne 18px weight 700
    "Tuesday . Day [streak]"  DM Mono 9px textMuted uppercase letter-spacing 1.5
  )
  Right: CircleAvatar(radius:17, gradient pink to violet, border white 1.5px opacity 0.2)
```

**The Stira Orb (center of screen):**
- Wrap in `GestureDetector` — tap opens check-in
- Size: 120x120
- Use `AnimatedBuilder` with `AnimationController(duration: 3s, repeat)`
- Orb gradient: `RadialGradient(center: Alignment(-0.2,-0.3), colors: [Color(0xFFF5A623), Color(0xFFE8307A).withOpacity(0.6), Colors.transparent], stops:[0.0, 0.55, 0.85])`
- Primary shadow: `BoxShadow(color: Color(0x66F5A623), blurRadius: 50, spreadRadius: 8)`
- Secondary shadow: `BoxShadow(color: Color(0x26F5A623), blurRadius: 100)`
- Pulse animation: scale 1.0 to 1.06, shadows grow/shrink in sync
- Outer ring: `Container` around orb, size 160x160, `BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color(0x33F5A623), width:1))` — also scale-animate opposite phase
- Below orb:
  - Status dot + text: `Row(dot, "Moderate intensity")` — DM Mono 9px, amber color
  - Label: "Your state right now" — Syne 13px weight 600

**REMOVE the lock icon from Forecast card completely**

**Metric cards grid (below orb):**
Use a `Column` of `Row`s:

```
Row 1: [Streak Card — pink] [Stability Card — teal]
Row 2: [Forecast Card — amber, full width]
```

**Streak Card (pink):**
- GlassCard accent: pink
- Label: DM Mono 9px "CURRENT STREAK"
- Value: LED Metric widget "12" + "d" — pink
- Sub: DM Sans 10px "Personal best: 18d"

**Stability Card (teal):**
- GlassCard accent: teal
- Label: DM Mono 9px "STABILITY SCORE"
- Value: LED Metric widget "84" + "%" — teal
- Sub: DM Sans 10px "Up 6pts this week"

**Forecast Card (amber — spans full width):**
- GlassCard accent: amber
- Label: DM Mono 9px "FORECAST — NEXT 4H"
- Value: DM Mono 15px amber "Low vulnerability window"
- Mini progress bar: height 3, borderRadius 2, background `glassBorder`, filled portion `LinearGradient(pink to amber)`, width 35% of card
- Sub text: DM Sans 10px "Stira predicts stability through 11 PM"
- NO LOCK ICON — remove it entirely

**Action buttons (bottom of cards area):**
Three buttons in a Row:
1. **Check-in** — flex:1, pink gradient background, Syne 12px weight 700, pink glow shadow. `BoxShadow(color: Color(0x4DE8307A), blurRadius: 20, offset: Offset(0,6))`
2. **Pause** — fixed width, GlassCard style, glassBorder border, textMuted color, Syne 12px
3. **Reset** — fixed width, NO background, text color `pink.withOpacity(0.65)`, Syne 12px — this indicates a destructive action

**Bottom Navigation Bar:**
```dart
BottomNavigationBar(
  backgroundColor: Color(0xB307060F),  // 70% opacity bgDeep
  // Add blur: wrap in ClipRect + BackdropFilter blur(20)
  selectedItemColor: pink,
  unselectedItemColor: textMuted,
  type: BottomNavigationBarType.fixed,
  // Items: Home, Insights, Tools, Profile
  // selectedLabelStyle: DM Mono 8px
  // unselectedLabelStyle: DM Mono 8px
)
```
Active tab icon: wrap selected icon in `DecoratedBox` with glow effect: `BoxDecoration(boxShadow: [BoxShadow(color: pink, blurRadius: 8)])`

---

### SCREEN 5 — DAILY CHECK-IN
**File:** Check-in screen

**Current state:** Unknown — find it. It likely has a rating mechanism.

**What to build:**

**Background:** `bgDeep` + teal radial glow: `RadialGradient(center: Alignment(0, 0.1), colors: [Color(0x261ECFB3), transparent])`

**Header:**
- Back button: 28x28 circle, GlassCard, back arrow icon
- Title: "Daily Check-in" Syne 16px weight 700

**Radial Dial (intensity selector — like Veri's sensor scan):**
- Center widget: 160x160 total
- Outer ring: `CustomPaint` drawing 60 tick marks around circle, alternating tall (12px) and short (6px), color `teal.withOpacity(0.35)`, animated rotate slowly (20s full rotation)
- Dashed ring: `CustomPaint` with dashed path around the circle
- Inner circle: 90x90, `GestureDetector` for rotation, `RadialGradient(colors: [teal.withOpacity(0.3), teal.withOpacity(0.05)])`, border `teal.withOpacity(0.4)`, glow shadow
- Inside inner circle: LED number (1-10) in DM Mono 26px teal with glow + "/ 10" DM Mono 10px below
- User rotates the dial (or swipe up/down) to change value 1-10
- Below dial: DM Mono 9px teal "URGE INTENSITY . NOW"

**Questions section (scroll below dial):**
Each question in a GlassCard (accent: teal):
- Question text: DM Sans 13px textPrimary
- Answer chips: `Wrap` of pill buttons:
  - Unselected: glassBorder border, textMuted, DM Mono 10px
  - Selected: teal background 15% opacity, teal border, teal text
  - 200ms AnimatedContainer transition

**Questions to include:**
1. "What triggered the urge?" — chips: Boredom, Stress, Loneliness, Anger, Tiredness, No reason
2. "Where are you?" — chips: Home, Bedroom, Work, Outside, Other
3. "How's your energy?" — chips: Low, Normal, High

**Submit button:** Full width, teal gradient `LinearGradient(colors: [teal, Color(0xFF15A090)])`, text color `bgDeep`, Syne 14px weight 700, glow shadow teal

---

### SCREEN 6 — INSIGHTS / ANALYTICS
**File:** Insights/stats screen

**Current state:** Some charts/stats screen

**What to build:**

**Background:** `bgDeep` + violet radial glow top-right

**Header:**
- Title: "Your Insights" — Syne 22px weight 800
- Subtitle: DM Mono 9px textMuted "WEEK OF [DATE]"

**Streak card (full width, amber):**
- GlassCard accent: amber
- Row: `[LED number "12" amber 36px] [Column: "Day Streak" Syne 14px bold / "Best: 18 days" DM Sans 11px muted] [flame emoji 28px]`

**Weekly bar chart card (violet):**
- GlassCard accent: violet
- Label: DM Mono 9px "URGE INTENSITY . 7 DAYS"
- Custom bar chart: 7 bars (M T W T F S S)
- Each bar: `AnimatedContainer` height based on data (0-100%), width flex
- Bar fill: `LinearGradient(colors: [violet, violet.withOpacity(0.3)])` top to bottom
- Latest day: use teal gradient instead to highlight today
- Day labels: DM Mono 8px textMuted below each bar
- Bars animate in on screen load (staggered, 50ms delay each)

**Top triggers card (pink):**
- GlassCard accent: pink
- Label: DM Mono 9px "TOP TRIGGERS"
- `Wrap` of colored chips:
  - Boredom 42% — pink chip
  - Stress 28% — amber chip
  - Loneliness 18% — violet chip

**Time-of-day heatmap card (teal):**
- GlassCard accent: teal
- Label: DM Mono 9px "MOST VULNERABLE HOURS"
- Row of 24 small blocks (hours 0-23), each colored from transparent to teal based on intensity
- Tap a block to see the hour label

**Weekly Report CTA (bottom of this screen):**
- Full width GlassCard accent: violet
- "View Weekly Stability Report" Syne 14px weight 700 violet color with arrow
- This is the ONLY place this button lives (remove from Profile submenu, put it here)

---

### SCREEN 7 — TOOLS / INTERVENTIONS
**File:** Tools or Reset screen (currently mixed with other screens)

**Separate this into its own tab in the bottom nav (the Tools icon)**

**Background:** `bgDeep` + soft pink radial glow

**Header:** "Intervention Toolkit" Syne 20px weight 800

**Tool cards (vertical scroll):**

**Card 1 — Reset Protocol (pink):**
- GlassCard accent: pink
- Icon: breathing emoji in pink circle
- Title: "90-Second Reset" Syne 15px bold pink
- Subtitle: DM Sans 12px "A guided breathing session to break the autopilot"
- Button: pink gradient "Start Reset"

**Card 2 — 4-4-4 Breathing (teal):**
- GlassCard accent: teal
- Icon: wind emoji in teal circle
- Title: "4-4-4 Breathing" Syne 15px bold teal
- Subtitle (REWRITE — do NOT use old copy): DM Sans 12px "Inhale 4s . Hold 4s . Exhale 4s. The simplest regulation tool. Let us guide you."
- Animated breathing circle: a circle that expands during inhale, holds, contracts during exhale — teal glow
- Button: teal gradient "Begin Session"

**Card 3 — The Vault (amber):**
- GlassCard accent: amber
- Icon: key emoji in amber circle
- Title: "The Vault" Syne 15px bold amber
- Subtitle: DM Sans 12px "Letters from your past self, waiting for this moment."
- Button: amber gradient "Open Vault"

**Card 4 — Message to Future Self (violet):**
- GlassCard accent: violet
- Icon: writing emoji in violet circle
- Title: "Write to Future You" Syne 15px bold violet
- Subtitle: DM Sans 12px "Leave a message for the version of you who needs it most."
- Button: violet gradient "Write Now"

---

### SCREEN 8 — DANGER ZONES
**File:** Danger zones / high-risk locations screen

**Current state:** Title, large empty space, "No zones tracked", "Pin Current Location" button at bottom

**What to change:**

**Background:** `bgDeep` + pink ambient glow

**Header:**
- Back button (circle, GlassCard)
- "High-Risk Locations" Syne 16px weight 700

**Map placeholder (when no zones yet OR as background for existing zones):**
- `Container` height 160, borderRadius 16
- Background: `Color(0x0AFFFFFF)` — very subtle
- Border: `glassBorder`
- Inside: grid pattern overlay (use `CustomPaint` to draw a grid of lines, color white at 15% opacity, spacing 20px)
- If zones exist: show animated pulsing pin circles at relative positions
  - Each pin: `Container` with pink background 15% opacity, pink border 1.5px, pulsing ring animation (scale 1.0 to 1.3, fade out, 2s repeat)
  - Pin emoji inside

**Zone count label:** DM Mono 9px textMuted "[N] zones tracked"

**Zone list items (GlassCard each, accent: pink):**
Each zone row:
- Left: icon in pink circle background
- Middle: zone name Syne 13px / trigger count DM Sans 10px textMuted
- Right: colored dot — high frequency = pink glow, low = amber glow

**Empty state (when no zones):**
Replace blank space with:
- Pink pulsing circle (animated) in center of map area
- Text: "No zones pinned yet." DM Sans 13px textMuted
- Sub: "Pinning a zone lets Stira alert you before the autopilot kicks in." DM Sans 11px textMuted

**Add button:**
- Full width, height 50, borderRadius 14
- Dashed border: pink at 35% opacity (use CustomPaint for dashed border)
- Background: pinkSoft
- Text: "+ Pin Current Location" pink, Syne 13px weight 700

---

### SCREEN 9 — PROFILE
**File:** Profile screen

**Current state:** Profile title, toggles, menu items

**What to change:**

**Background:** Linear gradient `bgDeep to bgCard` top to bottom

**Avatar section (top, centered):**
- Circle 72x72: gradient pink to violet, white border 2px at 15% opacity
- Glow: `BoxShadow(color: Color(0x4DE8307A), blurRadius: 30)`
- Person emoji or initials inside
- Name: Syne 17px weight 700
- "Member since [month] [year]" — DM Mono 9px textMuted

**Stats row (3 cards):**
Three equal GlassCards side by side:
- Streak: LED "12" pink / "Day streak" DM Mono 8px textMuted
- Stability: LED "84%" teal glow
- Check-ins: LED "23" amber glow

**Menu items (GlassCard each):**
Each item:
- Left icon in colored circle (size 30x30, borderRadius 8)
- Text: name Syne 13px weight 600 / description DM Sans 10px textMuted
- Right: either toggle OR arrow

**Menu items with descriptions (add these — currently missing descriptions):**
1. Bell icon "Daily Reminders" / "8 AM . 10 PM" — Toggle (pink, on)
2. Lock icon "Biometric Lock" / "FaceID keeps your data private" — Toggle (pink, on)
3. Key icon "The Vault" / "Letters to your future self" — Arrow
4. Map pin icon "Danger Zones" / "Locations that trigger you" — Arrow
5. Pencil icon "Edit Future You Message" / "Update what you wrote" — Arrow
6. REMOVE "Weekly Report" from profile — it belongs on Insights tab

**Toggles:**
- `Switch` with `activeColor: pink`, `activeTrackColor: pinkSoft`
- Add a box shadow on the Switch when on: `BoxShadow(color: Color(0x4DE8307A), blurRadius: 8)`

---

## GLOBAL CHANGES (apply to ALL screens)

### 1. Scaffold backgrounds
Every Scaffold: `backgroundColor: StiraTheme.bgDeep`
Never use `Colors.black` or default dark theme colors again.

### 2. All text
Never use `Colors.white` directly.
Use `StiraTheme.textPrimary` for primary text.
Use `StiraTheme.textMuted` for secondary/description text.
Use `GoogleFonts.syne()` for headings and CTAs.
Use `GoogleFonts.dmMono()` for numbers, labels, tags.
Use `GoogleFonts.dmSans()` for body text.

### 3. All cards / containers
Replace every plain `Container` with rounded corners used as a card — replace with `GlassCard` widget.
Every card gets: blur, gradient fill, colored border — using `StiraTheme` colors.

### 4. Bottom navigation
Wrap the entire `BottomNavigationBar` in:
```dart
ClipRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: BottomNavigationBar(...)
  )
)
```
- backgroundColor: `Color(0xB307060F)` (70% opacity)
- selectedItemColor: `StiraTheme.pink`
- unselectedItemColor: `StiraTheme.textMuted`

### 5. All buttons (CTAs)
Primary: pink gradient + glow shadow
Secondary: GlassCard style (glass bg + border)
Destructive: No background, pink text at 65% opacity
All use Syne font, weight 700.

### 6. Animations — add these everywhere
- All card entrances: `FadeTransition` + `SlideTransition` (from bottom, 200ms, staggered)
- Orb: continuous scale pulse (3s, repeat)
- Dial on check-in: continuous slow rotation (20s, repeat)
- Bar chart: animate heights on screen mount
- Selection state changes: 200ms AnimatedContainer
- Button press: scale down to 0.96 on tap (use GestureDetector + AnimatedScale)

### 7. Section labels
All uppercase category labels (like "FORECAST", "CURRENT STREAK"):
DM Mono, 9-10px, letterSpacing 2.5, color textMuted, text UPPERCASE.
These replace the old card titles that used regular font.

---

## THINGS YOU MUST NOT DO

1. Do NOT change any data models or business logic
2. Do NOT change route names or navigation logic
3. Do NOT break the check-in save functionality
4. Do NOT remove the danger zones location feature logic
5. Do NOT change the streak counter logic
6. Do NOT use Colors.purple anywhere — use StiraTheme.violet only
7. Do NOT use Inter, Roboto, or system fonts — use only Syne, DM Mono, DM Sans
8. Do NOT put a lock icon on the Forecast card
9. Do NOT leave the "No app needed" copy in the breathing card
10. Do NOT keep the 3 action buttons (Check-in / Pause / Reset) looking identical
11. Do NOT forget resizeToAvoidBottomInset: true on the signup screen
12. Do NOT hardcode any color — always use StiraTheme.[colorName]

---

## CHECKLIST — VERIFY BEFORE FINISHING

Go through every item. Do not mark done unless it is visually confirmed.

**Design System:**
- [ ] stira_theme.dart created with all colors and text styles
- [ ] glass_card.dart widget created and working
- [ ] led_metric.dart widget created and working
- [ ] google_fonts package added to pubspec.yaml

**Splash Screen:**
- [ ] bgDeep background with pink radial glow
- [ ] Orb pulses (scale animation, 3s repeat)
- [ ] Syne font for "stira" name
- [ ] DM Mono for tagline

**Onboarding:**
- [ ] Progress bar is animated segments (not dots)
- [ ] Option buttons have active/inactive states with pink glow
- [ ] Continue button has pink gradient + glow

**Sign Up:**
- [ ] Keyboard no longer covers button (resizeToAvoidBottomInset)
- [ ] GlassCard-style text fields
- [ ] Social login buttons present
- [ ] Pink gradient CTA button

**Dashboard:**
- [ ] bgDeep + amber ambient glow behind orb
- [ ] Orb pulses, has outer ring, tappable
- [ ] LED metrics: streak (pink), stability (teal)
- [ ] Forecast card: amber, NO lock icon, mini progress bar
- [ ] 3 buttons are visually distinct (primary / ghost / text)
- [ ] Bottom nav has blur + pink active glow

**Check-in:**
- [ ] Radial dial with tick marks (CustomPaint)
- [ ] LED number in center (1-10, teal glow)
- [ ] Trigger chips in GlassCard
- [ ] Teal gradient submit button

**Insights:**
- [ ] Amber streak card with LED number
- [ ] Violet animated bar chart (staggered animation)
- [ ] Pink trigger chips
- [ ] Teal hourly heatmap
- [ ] Weekly Report CTA at bottom (violet)

**Tools screen (new tab):**
- [ ] Separated into its own bottom nav tab
- [ ] 4 tool cards, each with correct accent color
- [ ] Breathing card copy is rewritten
- [ ] Animated breathing circle in 4-4-4 card

**Danger Zones:**
- [ ] Map grid background (CustomPaint)
- [ ] Animated pulsing pins
- [ ] Zone list in GlassCards
- [ ] Empty state with helpful copy
- [ ] Dashed "Pin Location" button

**Profile:**
- [ ] Gradient avatar with glow
- [ ] 3 stat cards (LED metrics)
- [ ] All menu items have descriptions
- [ ] Weekly Report removed from here
- [ ] Toggles are pink with glow

---

## PUBSPEC DEPENDENCIES TO ADD (if not already present)

```yaml
dependencies:
  google_fonts: ^6.1.0
  # All other existing dependencies — keep them all
```

Run `flutter pub get` after adding.

---

## IMPLEMENTATION ORDER

Implement in this exact order to avoid breaking things:

1. Create stira_theme.dart — design tokens
2. Create glass_card.dart — reusable widget
3. Create led_metric.dart — reusable widget
4. Update pubspec.yaml — add google_fonts
5. Splash screen
6. Onboarding screens
7. Sign up screen (fix keyboard bug first)
8. Dashboard (home) — most complex, take your time
9. Check-in screen
10. Insights screen
11. Tools screen (may need new file + new nav tab)
12. Danger zones screen
13. Profile screen
14. Global: bottom nav blur + active states
15. Final pass: verify every screen matches checklist above

---

End of master prompt. Read it fully before starting. Implement completely. Do not skip steps.
