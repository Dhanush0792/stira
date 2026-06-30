import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../theme/stira_tokens.dart';
import '../../widgets/stira_glass_card.dart';
import '../../widgets/stira_primary_button.dart';
import '../../services/local_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/stira_intelligence_engine.dart';

class DopamineJournalScreen extends StatefulWidget {
  const DopamineJournalScreen({super.key});

  @override
  State<DopamineJournalScreen> createState() => _DopamineJournalScreenState();
}

class _DopamineJournalScreenState extends State<DopamineJournalScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  final TextEditingController _noteCtrl = TextEditingController();
  
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Exercise', 'icon': Icons.directions_run, 'isPositive': true},
    {'name': 'Learning', 'icon': Icons.menu_book, 'isPositive': true},
    {'name': 'Socializing', 'icon': Icons.people, 'isPositive': true},
    {'name': 'Gaming', 'icon': Icons.videogame_asset, 'isPositive': false},
    {'name': 'Scrolling', 'icon': Icons.phone_android, 'isPositive': false},
    {'name': 'Junk Food', 'icon': Icons.fastfood, 'isPositive': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final storage = StorageService();
    final entries = storage.getDopamineEntries();
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  void _saveEntry() async {
    if (_selectedCategory == null) return;
    final catData = _categories.firstWhere((c) => c['name'] == _selectedCategory);
    
    final newEntry = {
      'date': _selectedDate.toIso8601String(),
      'category': _selectedCategory,
      'note': _noteCtrl.text,
      'isPositive': catData['isPositive'],
    };

    final storage = StorageService();
    await storage.addDopamineEntry(newEntry);
    await Hive.box('check_ins').add({
      'type': 'journal',
      'timestamp': _selectedDate.toIso8601String(),
      'note': _noteCtrl.text,
    });
    
    setState(() {
      _entries.insert(0, newEntry);
      _selectedCategory = null;
      _noteCtrl.clear();
      _selectedDate = DateTime.now();
    });

    await StiraIntelligenceEngine.reactToAction(UserAction.checkInSubmitted);
    
    // Close keyboard
    FocusScope.of(context).unfocus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log saved.')),
      );
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Stack(
        children: [
          // Subtle glow
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StiraTokens.stiraViolet.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                            border: Border.all(color: StiraTokens.stiraWhite.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(Icons.arrow_back, size: 16, color: StiraTokens.stiraWhite),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Dopamine Journal',
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: StiraTokens.stiraWhite,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: StiraTokens.stiraViolet))
                    : SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Track where you get your dopamine.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: StiraTokens.stiraMuted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // New Entry Form
                        StiraGlassCard(
                          accentColor: StiraTokens.stiraViolet,
                          fullWidth: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NEW ENTRY', style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.bold, color: StiraTokens.stiraViolet, letterSpacing: 1.2)),
                              const SizedBox(height: 16),
                              
                              // Date Picker
                              GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.dark(
                                            primary: StiraTokens.stiraViolet,
                                            onPrimary: StiraTokens.stiraBg,
                                            surface: StiraTokens.stiraBg2,
                                            onSurface: StiraTokens.stiraWhite,
                                          ),
                                          dialogBackgroundColor: StiraTokens.stiraBg2,
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (date != null) setState(() => _selectedDate = date);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: StiraTokens.stiraGlass,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: StiraTokens.stiraGlassBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: StiraTokens.stiraViolet, size: 16),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(_selectedDate),
                                        style: GoogleFonts.dmSans(fontSize: 14, color: StiraTokens.stiraWhite),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Category Selection
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _categories.map((c) {
                                  final isSelected = _selectedCategory == c['name'];
                                  final isPositive = c['isPositive'] as bool;
                                  final color = isPositive ? StiraTokens.stiraTeal : StiraTokens.stiraPink;
                                  
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedCategory = c['name'] as String),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? color.withValues(alpha: 0.2) : StiraTokens.stiraGlass,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: isSelected ? color : StiraTokens.stiraGlassBorder),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(c['icon'] as IconData, size: 14, color: isSelected ? color : StiraTokens.stiraMuted),
                                          const SizedBox(width: 6),
                                          Text(
                                            c['name'] as String,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                              color: isSelected ? color : StiraTokens.stiraMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              
                              // Note Input
                              RepaintBoundary(
                                child: TextField(
                                  controller: _noteCtrl,
                                  style: GoogleFonts.dmSans(fontSize: 14, color: StiraTokens.stiraWhite),
                                  decoration: InputDecoration(
                                    hintText: 'How did it make you feel afterwards?',
                                    hintStyle: GoogleFonts.dmSans(color: StiraTokens.stiraMuted),
                                    filled: true,
                                    fillColor: StiraTokens.stiraBg.withValues(alpha: 0.5),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Save Action
                              StiraPrimaryButton(
                                label: 'Log Activity',
                                color: StiraTokens.stiraViolet,
                                onTap: _saveEntry,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // History List
                        Text('RECENT HISTORY', style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.bold, color: StiraTokens.stiraMuted, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        
                        if (_entries.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No entries yet. Start logging your activities!',
                                style: GoogleFonts.dmSans(color: StiraTokens.stiraMuted),
                              ),
                            ),
                          ),

                        ..._entries.map((entry) {
                          final isPos = entry['isPositive'] as bool;
                          final color = isPos ? StiraTokens.stiraTeal : StiraTokens.stiraPink;
                          final catData = _categories.firstWhere((c) => c['name'] == entry['category'], orElse: () => _categories.first);
                          final catIcon = catData['icon'] as IconData;
                          final date = entry['date'] is String ? DateTime.parse(entry['date'] as String) : entry['date'] as DateTime;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StiraGlassCard(
                              accentColor: color.withValues(alpha: 0.5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(catIcon, color: color, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              entry['category'] as String,
                                              style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: StiraTokens.stiraWhite),
                                            ),
                                            Text(
                                              DateFormat('MMM d').format(date),
                                              style: GoogleFonts.dmMono(fontSize: 11, color: StiraTokens.stiraMuted),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry['note'] as String,
                                          style: GoogleFonts.dmSans(fontSize: 13, color: StiraTokens.stiraMuted, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
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
