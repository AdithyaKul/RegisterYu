import 'package:flutter/material.dart';

class AppColors {
  // Deep Backgrounds - The "Void"
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color surfaceCharcoal = Color(0xFF121212);
  
  // Liquid Glass - The "Lens"
  // We use white with very low opacity for the glass layers
  static const Color glassWhiteLow = Color.fromRGBO(255, 255, 255, 0.05); // 5%
  static const Color glassWhiteMedium = Color.fromRGBO(255, 255, 255, 0.10); // 10%
  static const Color glassWhiteHigh = Color.fromRGBO(255, 255, 255, 0.20); // 20%
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.15); // Thin border
  
  // Accents - "Tech Neon" but subtle
  static const Color accentBlue = Color(0xFF2997FF); // iOS Blue
  static const Color accentPurple = Color(0xFFBF5AF2); // iOS Purple
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color.fromRGBO(235, 235, 245, 0.60); // iOS Gray

  // Light Mode Colors
  static const Color backgroundWhite = Color(0xFFF2F2F7); // iOS System Gray 6
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color.fromRGBO(60, 60, 67, 0.60); // iOS Light Gray
}
