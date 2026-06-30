import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherDisguise extends StatelessWidget {
  final VoidCallback onUnlock;
  const WeatherDisguise({super.key, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onUnlock,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/shadow_mode/weather.png', width: 32, height: 32),
                      const Icon(Icons.search, color: Colors.white70),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('San Francisco', style: GoogleFonts.dmSans(fontSize: 28, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Partly Cloudy', style: GoogleFonts.dmSans(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 24),
                const Icon(Icons.cloud_queue, size: 100, color: Colors.white),
                const SizedBox(height: 24),
                Text('68\u00B0', style: GoogleFonts.syne(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 48),
                _buildForecastRow(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForecastRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((d) => Column(
          children: [
            Text(d, style: GoogleFonts.dmSans(color: Colors.grey)),
            const SizedBox(height: 8),
            const Icon(Icons.wb_cloudy_outlined, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            Text('65\u00B0', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        )).toList(),
      ),
    );
  }
}

class CalculatorDisguise extends StatelessWidget {
  final VoidCallback onUnlock;
  const CalculatorDisguise({super.key, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onUnlock,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset('assets/shadow_mode/calculator.png'),
          ),
          title: Text('Calculator', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16)),
        ),
        body: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Text('0', style: GoogleFonts.dmSans(fontSize: 84, color: Colors.white, fontWeight: FontWeight.w300)),
            ),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final List<List<String>> keys = [
      ['AC', '+/-', '%', '/'],
      ['7', '8', '9', 'X'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '=']
    ];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: keys.map((row) => Row(
          children: row.map((key) => Expanded(
            flex: key == '0' ? 2 : 1,
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 70,
              decoration: BoxDecoration(
                color: _btnColor(key),
                shape: key == '0' ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: key == '0' ? BorderRadius.circular(35) : null,
              ),
              alignment: Alignment.center,
              child: Text(key, style: GoogleFonts.dmSans(fontSize: 24, color: _textColor(key), fontWeight: FontWeight.w500)),
            ),
          )).toList(),
        )).toList(),
      ),
    );
  }

  Color _btnColor(String k) {
    if (['AC', '+/-', '%'].contains(k)) return Colors.grey;
    if (['/', 'X', '-', '+', '='].contains(k)) return Colors.orange;
    return const Color(0xFF333333);
  }

  Color _textColor(String k) {
    if (['AC', '+/-', '%'].contains(k)) return Colors.black;
    return Colors.white;
  }
}

class FinanceDisguise extends StatelessWidget {
  final VoidCallback onUnlock;
  const FinanceDisguise({super.key, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onUnlock,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/shadow_mode/finance.png', width: 40, height: 40),
                    const Icon(Icons.notifications_none, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Total Balance', style: GoogleFonts.dmSans(color: Colors.grey)),
                const SizedBox(height: 8),
                Text('\$12,450.80', style: GoogleFonts.dmMono(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('+\$450.20 (3.2%)', style: GoogleFonts.dmSans(color: Colors.greenAccent)),
                const SizedBox(height: 48),
                _buildAssetRow('BTC', 'Bitcoin', '\$52,140.00', '+1.2%'),
                const SizedBox(height: 16),
                _buildAssetRow('ETH', 'Ethereum', '\$2,840.50', '-0.5%'),
                const SizedBox(height: 16),
                _buildAssetRow('AAPL', 'Apple Inc.', '\$182.30', '+0.8%'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetRow(String s, String n, String p, String c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle), alignment: Alignment.center, child: Text(s[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(n, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(p, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(c, style: TextStyle(color: c.startsWith('+') ? Colors.greenAccent : Colors.redAccent, fontSize: 12))]),
        ],
      ),
    );
  }
}

class NotesDisguise extends StatelessWidget {
  final VoidCallback onUnlock;
  const NotesDisguise({super.key, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onUnlock,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFAED),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/shadow_mode/notes.png', width: 32, height: 32),
                    Text('All Notes', style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const Icon(Icons.search, color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 32),
                _buildNoteItem('Grocery List', 'Milk, eggs, bread, coffee...'),
                const Divider(),
                _buildNoteItem('Quotes to Remember', 'The only way to do great work is to...'),
                const Divider(),
                _buildNoteItem('Meeting Notes', 'Discuss the Q1 projections and budget...'),
                const Divider(),
                _buildNoteItem('Travel Ideas', 'Japan, Iceland, Portugal...'),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {}, backgroundColor: Colors.orange, child: const Icon(Icons.add)),
      ),
    );
  }

  Widget _buildNoteItem(String t, String s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 4),
          Text(s, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
