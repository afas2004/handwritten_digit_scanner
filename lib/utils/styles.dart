import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF1A227F); // Deep Blue
  static const Color background = Color(0xFFF6F6F8); // Soft Grey
  static const Color surface = Colors.white;
  static const Color textMain = Color(0xFF121217);
  static const Color textSub = Color(0xFF666985);
  static const Color accent = Color(0xFF3F4CB0);
}

class AppTextStyles {
  static TextStyle get header => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textMain
  );
  
  static TextStyle get cardTitle => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.surface
  );
  
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14, color: AppColors.textSub
  );
}