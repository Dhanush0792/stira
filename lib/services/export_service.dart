import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'local_storage.dart';

class ExportService {
  final StorageService _storage = StorageService();

  Future<void> exportClinicalData() async {
    final logs = _storage.getCheckinHistory();
    final relapses = _storage.getRelapseTriggers();

    // 1. Prepare Data Rows
    List<List<dynamic>> rows = [];
    
    // Check-in Header
    rows.add(['--- CHECK-INS ---']);
    rows.add(['Timestamp', 'Urge Level', 'Mood', 'Alone']);

    // Check-in Data
    for (var log in logs) {
      rows.add([
        log['timestamp'] ?? 'Unknown',
        log['urge'] ?? 0,
        log['mood'] ?? 'None',
        log['alone'] == true ? 'Yes' : 'No',
      ]);
    }

    rows.add([]); // Blank line separator

    // Relapse Header
    rows.add(['--- RELAPSE AUTOPSY ---']);
    rows.add(['Timestamp', 'Location', 'Emotion', 'Trigger']);

    // Relapse Data
    for (var r in relapses) {
      rows.add([
        r['timestamp'] ?? 'Unknown',
        r['location'] ?? 'Unknown',
        r['emotion'] ?? 'Unknown',
        r['trigger'] ?? 'Unknown',
      ]);
    }

    // 2. Convert to CSV String manually to avoid generic inference issues
    String csvData = rows.map((row) {
      if (row.isEmpty) return "";
      return row.map((e) {
        String val = e.toString().replaceAll('"', '""');
        if (val.contains(',') || val.contains('\\n') || val.contains('"')) {
          return '"\$val"';
        }
        return val;
      }).join(',');
    }).join('\n');

    // 3. Write to Temp File
    final dir = await getTemporaryDirectory();
    final dateStr = DateTime.now().toIso8601String().split('T').first;
    final file = File('${dir.path}/stira_clinical_report_$dateStr.csv');
    await file.writeAsString(csvData);

    // 4. Trigger Share UI
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Stira Clinical Stability Report',
    );
  }
}
