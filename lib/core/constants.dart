import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'CaLtrack AI';
  static const String appTagline = 'Smart AI Calorie & Macro Tracking';
  static const String appVersion = '1.0.0';

  // Accent Colors Available for Customization
  static const List<Color> accentColors = [
    Color(0xFF10B981), // Emerald Green (Default)
    Color(0xFF3B82F6), // Electric Blue
    Color(0xFF8B5CF6), // Royal Violet
    Color(0xFFF43F5E), // Crimson Rose
    Color(0xFFF59E0B), // Sunset Amber
    Color(0xFF14B8A6), // Ocean Teal
  ];

  static const List<String> accentColorNames = [
    'Emerald',
    'Blue',
    'Violet',
    'Rose',
    'Amber',
    'Teal',
  ];

  // Dark Theme Palette
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Palette
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Macro Colors
  static const Color proteinColor = Color(0xFFEF4444); // Red/Coral
  static const Color carbsColor = Color(0xFF3B82F6);    // Blue
  static const Color fatColor = Color(0xFFF59E0B);      // Amber/Gold
  static const Color waterColor = Color(0xFF06B6D4);    // Cyan
  static const Color burnedColor = Color(0xFF8B5CF6);   // Violet

  // Storage Keys
  static const String keyProfile = 'caltrack_user_profile';
  static const String keyLogs = 'caltrack_daily_logs';
  static const String keyWeight = 'caltrack_weight_logs';
  static const String keyCustomFoods = 'caltrack_custom_foods';
}
