import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';
import '../services/history_service.dart'; // Import the service
import 'camera_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ScanRecord> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadRecentActivity();
  }

  // Fetch data from local storage
  Future<void> _loadRecentActivity() async {
    final allHistory = await HistoryService.getHistory();
    setState(() {
      // Take only the top 3 items for the "Recent" list
      _recentActivity = allHistory.take(3).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.document_scanner, color: AppColors.primary),
            const SizedBox(width: 8),
            Text("Digitize", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textMain)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textSub),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, Student", style: AppTextStyles.header),
            Text("Ready to digitize your notes?", style: AppTextStyles.body),
            const SizedBox(height: 24),
            
            // Hero Card (Start Scan)
            GestureDetector(
              onTap: () async {
                // Navigate to Camera, and wait for it to return
                await Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const CameraScreen())
                );
                // When we come back, refresh the list!
                _loadRecentActivity();
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                  image: const DecorationImage(
                    image: AssetImage("assets/background.jpg"), // <--- USE THIS SYNTAX
                    fit: BoxFit.cover,
                    opacity: 0.6, // Keeps text readable
                  ),
                  // Simple gradient background instead of network image to prevent errors
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF3F4CB0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ],
                        
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text("AI Scanner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Start New Scan", style: AppTextStyles.cardTitle),
                    const Text("Recognize digits instantly", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            Text("Recent Activity", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
            const SizedBox(height: 16),
            
            // Dynamic List
            if (_recentActivity.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 10),
                    Text("No recent scans found.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ..._recentActivity.map((record) => _buildActivityItem(record)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ScanRecord record) {
    IconData icon = record.type == "Drawing" ? Icons.gesture : Icons.camera_alt;
    Color iconColor = record.type == "Drawing" ? Colors.purple : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Scanned: ${record.result}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                Text(
                  DateFormat('h:mm a • MMM d').format(record.date), 
                  style: const TextStyle(color: AppColors.textSub, fontSize: 12)
                ),
              ],
            ),
          ),
          Container(
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
        ],
      ),
    );
  }
}