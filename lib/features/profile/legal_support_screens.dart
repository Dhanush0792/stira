import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/stira_tokens.dart';
import '../../../widgets/stira_glass_card.dart';
import '../../../services/local_storage.dart';
import '../onboarding/welcome_screen.dart';

// ─── Play Store Compliant Legal & Support Screens ──────────────────────────────
// Tabs: Help & FAQ | Contact Us | Privacy Policy | Terms of Service
// Contact: missionhousehq@gmail.com (tappable mailto)
// Data Deletion: works for both authenticated and guest users
// ──────────────────────────────────────────────────────────────────────────────

const String _supportEmail = 'missionhousehq@gmail.com';
const String _appVersion = '1.0.0';

class LegalSupportScreen extends StatefulWidget {
  final int initialTabIndex;
  const LegalSupportScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LegalSupportScreen> createState() => _LegalSupportScreenState();
}

class _LegalSupportScreenState extends State<LegalSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail(String subject, String body) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.syne(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: StiraTokens.stiraWhite,
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.dmSans(
              color: StiraTokens.stiraWhite,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: GoogleFonts.dmSans(
              color: StiraTokens.stiraMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String label, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $label',
          style: GoogleFonts.dmSans(
            color: StiraTokens.stiraWhite,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.dmSans(
            color: StiraTokens.stiraMuted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFaqTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Frequently Asked Questions'),
          const SizedBox(height: 16),
          _faqItem('How does Stira Intelligence work?',
              'Stira runs fully locally on your device. Every time you check in, the engine analyzes your logged triggers and vulnerability windows to proactively remind you before high-risk moments arise.'),
          _faqItem('Is my data private?',
              'Yes. Stira uses a local-first architecture. Check-ins, journal entries, and Vault letters are stored in an encrypted local database (Hive NoSQL) on your device and are never uploaded to external servers.'),
          _faqItem('What happens if I reinstall the app?',
              'If you signed in with Google, your core profile and settings can be restored from your Firestore account. Guest users should use the Export feature before uninstalling to preserve their data.'),
          _faqItem('How do I delete my data?',
              'Signed-in users can use Profile → Delete Account. Guest users can use Profile → Clear All Local Data. You can also simply uninstall the app as all data is stored locally.'),
          const SizedBox(height: 16),
          _sectionTitle('Troubleshooting'),
          const SizedBox(height: 12),
          StiraGlassCard(
            accentColor: StiraTokens.stiraViolet,
            fullWidth: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bulletPoint('Notifications not arriving?',
                    'Check Settings → Apps → Stira and ensure notifications are enabled. The app also respects quiet hours and a 3-hour minimum gap between alerts.'),
                const SizedBox(height: 12),
                _bulletPoint('App crashing?',
                    'Make sure you\'re on the latest version. Anonymous crash reports help us fix issues rapidly. Contact support if the issue persists.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Version $_appVersion',
              style: GoogleFonts.dmMono(
                  color: StiraTokens.stiraMuted, fontSize: 11),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return _FeedbackForm(
      onLaunchEmail: _launchEmail,
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Privacy Policy'),
          const SizedBox(height: 4),
          Text('Effective Date: June 30, 2026',
              style: GoogleFonts.dmMono(
                  color: StiraTokens.stiraMuted, fontSize: 10)),
          const SizedBox(height: 16),
          StiraGlassCard(
            accentColor: StiraTokens.stiraTeal,
            fullWidth: true,
            child: Text(
              'Stira is built on a Local-First Architecture. Your personal and behavioral data stays on your device and is never sold.',
              style: GoogleFonts.dmSans(
                  color: StiraTokens.stiraWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          _faqItem('1. Information We Collect',
              '• Account Info: Email address or Google authentication tokens for login.\n• Crash Reports: Anonymous, aggregated crash diagnostics via Firebase Crashlytics.\n• Analytics: Anonymous app interaction events via Firebase Analytics (no personal data).\n• Device Info: OS version and model for troubleshooting purposes only.'),
          _faqItem('2. Information Stored Locally Only (Never Transmitted)',
              'The following data NEVER leaves your device:\n• Daily check-in responses (intensity, triggers, energy)\n• Dopamine Journal entries\n• "The Vault" letters\n• Behavioral forecasting patterns and vulnerability windows\n• Streak data and commitment records'),
          _faqItem('3. Third-Party Services',
              '• Google Firebase: Authentication, anonymous crash reporting, and analytics.\n• Google Sign-In: For account authentication only.\nWe do NOT share your data with advertisers, data brokers, or any third parties beyond the above.'),
          _faqItem('4. Your Rights (DPDP / GDPR)',
              '• Access: Request a copy of any data held about you.\n• Correction: Request correction of inaccurate data.\n• Deletion: Delete your account in-app (Profile → Delete Account) or email us at $_supportEmail with subject "Account Deletion Request".\n• Opt-Out: You may opt out of anonymous analytics by contacting us.'),
          _faqItem('5. Data Retention',
              'Account data is retained until you delete your account. Local data is deleted when you uninstall the app or use "Clear All Local Data".'),
          _faqItem('6. Children\'s Privacy',
              'Stira is not intended for users under the age of 13. We do not knowingly collect data from children.'),
          _faqItem('7. Contact for Privacy Concerns',
              'Email us at $_supportEmail with subject "Privacy: [Your Request]".'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTermsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Terms of Service'),
          const SizedBox(height: 4),
          Text('Last Updated: June 30, 2026',
              style: GoogleFonts.dmMono(
                  color: StiraTokens.stiraMuted, fontSize: 10)),
          const SizedBox(height: 16),
          StiraGlassCard(
            accentColor: const Color(0xFFFF3B30),
            fullWidth: true,
            child: Text(
              '⚕️ Stira is NOT a medical product. It does not provide clinical, psychological, or medical advice and is not a substitute for professional treatment.',
              style: GoogleFonts.dmSans(
                  color: StiraTokens.stiraWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          _faqItem('1. Acceptance of Terms',
              'By downloading or using the Stira application, you agree to be bound by these Terms of Service. If you do not agree, please do not use the App.'),
          _faqItem('2. Eligibility',
              'You must be at least 13 years old to use Stira. Users between 13–18 must have parental or guardian consent. By using the app, you represent that you meet these requirements.'),
          _faqItem('3. Description of Service',
              'Stira is a personal behavioral stability and self-regulation tool. It is designed to support self-awareness and habitual pattern recognition. It is NOT a licensed healthcare service and makes no guarantees about treatment outcomes.'),
          _faqItem('4. No Medical Advice',
              'Nothing in Stira constitutes medical, psychiatric, or clinical advice, diagnosis, or treatment. Always seek the advice of a qualified healthcare provider for any mental health concerns.'),
          _faqItem('5. User Data & Security',
              'You are responsible for maintaining the security of your device. Stira is not liable for data loss due to device transfers, uninstallation, OS resets, or loss of access credentials.'),
          _faqItem('6. Account Termination',
              'You may delete your account at any time via Profile → Delete Account. We reserve the right to suspend accounts that violate these terms.'),
          _faqItem('7. Disclaimer of Warranties',
              'Stira is provided "as is" without warranties of any kind. We do not warrant uninterrupted, error-free, or secure operation of the app.'),
          _faqItem('8. Governing Law',
              'These terms are governed by the laws of India. Any disputes shall be subject to the exclusive jurisdiction of courts in India.'),
          _faqItem('9. Contact for Disputes',
              'Email us at $_supportEmail with subject "Legal: [Your Concern]".'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          Container(decoration: StiraTokens.bgVioletCenterGlow),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                            border: Border.all(
                                color: StiraTokens.stiraWhite
                                    .withValues(alpha: 0.1)),
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 16, color: StiraTokens.stiraWhite),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Support & Legal',
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: StiraTokens.stiraWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: StiraTokens.stiraPink,
                  labelColor: StiraTokens.stiraWhite,
                  unselectedLabelColor: StiraTokens.stiraMuted,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Help & FAQ'),
                    Tab(text: 'Contact Us'),
                    Tab(text: 'Privacy Policy'),
                    Tab(text: 'Terms'),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFaqTab(),
                      _buildContactTab(),
                      _buildPrivacyTab(),
                      _buildTermsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackForm extends StatefulWidget {
  final Future<void> Function(String subject, String body) onLaunchEmail;
  const _FeedbackForm({required this.onLaunchEmail});

  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  String _issueType = 'General Support';
  final _summaryController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _issueTypes = [
    'General Support',
    'Report a Bug',
    'Account & Data Deletion',
    'Privacy Concern',
  ];

  @override
  void dispose() {
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final String subject = '$_issueType: ${_summaryController.text}';
      final String body = _descriptionController.text;
      widget.onLaunchEmail(subject, body);
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.syne(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: StiraTokens.stiraWhite,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Contact Us'),
            const SizedBox(height: 12),
            Text(
              'Select your issue below, fill in the details, and tap submit to send us an email.',
              style: GoogleFonts.dmSans(
                color: StiraTokens.stiraMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown Selector for Issue Type
            Text(
              'Select Issue Type',
              style: GoogleFonts.dmSans(
                color: StiraTokens.stiraWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: StiraTokens.stiraWhite.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: StiraTokens.stiraGlassBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _issueType,
                  dropdownColor: StiraTokens.stiraBg2,
                  icon: const Icon(Icons.arrow_drop_down, color: StiraTokens.stiraPink),
                  isExpanded: true,
                  style: GoogleFonts.dmSans(color: StiraTokens.stiraWhite, fontSize: 14),
                  items: _issueTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _issueType = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Issue Summary Bar (Max 50 characters)
            Text(
              'Issue Summary (Max 50 characters)',
              style: GoogleFonts.dmSans(
                color: StiraTokens.stiraWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _summaryController,
              maxLength: 50,
              style: GoogleFonts.dmSans(color: StiraTokens.stiraWhite, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Brief summary of the issue...',
                hintStyle: GoogleFonts.dmSans(color: StiraTokens.stiraMuted.withValues(alpha: 0.5)),
                filled: true,
                fillColor: StiraTokens.stiraWhite.withValues(alpha: 0.05),
                counterStyle: GoogleFonts.dmMono(color: StiraTokens.stiraMuted, fontSize: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: StiraTokens.stiraGlassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: StiraTokens.stiraPink),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a summary';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Detailed Description
            Text(
              'Detailed Description',
              style: GoogleFonts.dmSans(
                color: StiraTokens.stiraWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              style: GoogleFonts.dmSans(color: StiraTokens.stiraWhite, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Please describe the problem in detail...',
                hintStyle: GoogleFonts.dmSans(color: StiraTokens.stiraMuted.withValues(alpha: 0.5)),
                filled: true,
                fillColor: StiraTokens.stiraWhite.withValues(alpha: 0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: StiraTokens.stiraGlassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: StiraTokens.stiraPink),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StiraTokens.stiraPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Submit Issue',
                  style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Guest Data Deletion Screen ───────────────────────────────────────────────
// Standalone screen opened from Profile tab for guest users to wipe all local data.

class GuestDataDeletionScreen extends StatefulWidget {
  const GuestDataDeletionScreen({super.key});

  @override
  State<GuestDataDeletionScreen> createState() =>
      _GuestDataDeletionScreenState();
}

class _GuestDataDeletionScreenState extends State<GuestDataDeletionScreen> {
  bool _clearing = false;

  Future<void> _clearAllData() async {
    setState(() => _clearing = true);
    final storage = StorageService();
    await storage.clearAllLocalData();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: StiraTokens.stiraBg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                border: Border.all(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.delete_forever_outlined,
                  color: Color(0xFFFF3B30), size: 28),
            ),
            const SizedBox(height: 16),
            Text('Clear All Local Data',
                style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: StiraTokens.stiraWhite)),
            const SizedBox(height: 10),
            Text(
              'This will permanently erase all your check-ins, journal entries, vault letters, streaks, and settings from this device.\n\nThis cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: StiraTokens.stiraMuted, height: 1.6),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _clearing ? null : _clearAllData,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF3B30).withValues(alpha: 0.15),
                  foregroundColor: const Color(0xFFFF3B30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.4)),
                  ),
                  elevation: 0,
                ),
                child: _clearing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFFFF3B30)))
                    : Text('Clear All Data',
                        style: GoogleFonts.syne(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.dmSans(color: StiraTokens.stiraMuted)),
            ),
          ],
        ),
      ),
    );
  }
}
