import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handwritten_digit_scanner/screens/drawing_screen.dart';
import '../utils/styles.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeScreen(),
    const DrawingScreen(), // Added here as Index 1
    const HistoryScreen(), // Moved to Index 2
    const ProfileScreen(), // Moved to Index 3
  ];

  void _onScanPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: _onScanPressed,
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        color: AppColors.surface,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(0, Icons.dashboard_rounded, "Home"),
              _buildTabItem(1, Icons.gesture, "Draw"), // New Tab
              const SizedBox(width: 40), // Space for FAB (Scanner)
              _buildTabItem(2, Icons.history_rounded, "History"),
              _buildTabItem(3, Icons.person_rounded, "Profile"), // Optional 4th tab for balance, or just leave it empty
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 28),
          Text(label, style: GoogleFonts.inter(
            fontSize: 12, 
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : Colors.grey
          )),
        ],
      ),
    );
  }
}