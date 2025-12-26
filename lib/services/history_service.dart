import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScanRecord {
  final String result;     // e.g. "7" or "012"
  final double confidence; // e.g. 0.98
  final DateTime date;
  final String type;       // "Camera" or "Drawing"

  ScanRecord({
    required this.result,
    required this.confidence,
    required this.date,
    required this.type,
  });

  // Convert object to Text (JSON) to save
  Map<String, dynamic> toJson() => {
    'result': result,
    'confidence': confidence,
    'date': date.toIso8601String(),
    'type': type,
  };

  // Convert Text (JSON) back to object to read
  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      result: json['result'],
      confidence: json['confidence'] ?? 0.0,
      date: DateTime.parse(json['date']),
      type: json['type'] ?? 'Camera',
    );
  }
}

class HistoryService {
  static const String _key = 'scan_history';

  // Save a new scan
  static Future<void> addScan(String result, double confidence, String type) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Get existing list
    List<String> historyList = prefs.getStringList(_key) ?? [];
    
    // 2. Create new record
    final newRecord = ScanRecord(
      result: result,
      confidence: confidence,
      date: DateTime.now(),
      type: type,
    );
    
    // 3. Add to top of list (JSON format)
    historyList.insert(0, jsonEncode(newRecord.toJson()));
    
    // 4. Save back to storage
    await prefs.setStringList(_key, historyList);
  }

  // Get all scans
  static Future<List<ScanRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_key) ?? [];
    
    return historyList
        .map((item) => ScanRecord.fromJson(jsonDecode(item)))
        .toList();
  }

  // Clear all
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}