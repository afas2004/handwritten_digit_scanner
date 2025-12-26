import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/styles.dart';
import '../services/history_service.dart';
import '../main.dart'; // Import main to access themeNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  double _confidenceThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved values
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _confidenceThreshold = prefs.getDouble('confidenceThreshold') ?? 80.0;
    });
  }

  // Save Threshold
  Future<void> _updateThreshold(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('confidenceThreshold', val);
    setState(() => _confidenceThreshold = val);
  }

  // Toggle Dark Mode
  Future<void> _toggleDarkMode(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', val);
    
    setState(() => _isDarkMode = val);
    // Update the Global Theme
    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _handleClearHistory() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Clear", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.clearHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("History cleared.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on current theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2D) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textMain;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Settings", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("AI Configuration"),
            _settingCard(
              color: cardColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Confidence Threshold", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                      Text("${_confidenceThreshold.toInt()}%", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _confidenceThreshold,
                    min: 50,
                    max: 99,
                    activeColor: AppColors.primary,
                    onChanged: _updateThreshold, // Calls the save function
                  ),
                  Text(
                    "Note: This filter applies to the Camera view.",
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.grey : AppColors.textSub),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _sectionHeader("Preferences"),
            _settingCard(
              color: cardColor,
              child: SwitchListTile(
                title: Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                value: _isDarkMode,
                activeColor: AppColors.primary,
                onChanged: _toggleDarkMode, // Calls the toggle function
              ),
            ),

            const SizedBox(height: 24),
            _sectionHeader("Data Management"),
            _settingCard(
              color: cardColor,
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Clear Scan History", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: _handleClearHistory,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _settingCard({required Widget child, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: child,
    );
  }
}