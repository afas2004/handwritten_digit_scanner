import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';
import '../utils/styles.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Reload data whenever this screen appears
  Future<void> _loadData() async {
    final data = await HistoryService.getHistory();
    setState(() {
      _records = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Scan History"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              await HistoryService.clearHistory();
              _loadData(); // Refresh UI
            },
          )
        ],
      ),
      body: _records.isEmpty
          ? const Center(child: Text("No scans yet. Start digitizing!"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: record.type == "Drawing" 
                          ? Colors.purple.withOpacity(0.1) 
                          : AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        record.type == "Drawing" ? Icons.gesture : Icons.camera_alt,
                        color: record.type == "Drawing" ? Colors.purple : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      record.result,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      "${record.type} • ${DateFormat('MMM d, h:mm a').format(record.date)}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${(record.confidence * 100).toInt()}%",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}