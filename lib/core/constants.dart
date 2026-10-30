import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'CaLtrack AI';
  static const String appTagline = 'Smart AI Calorie & Macro Tracking';
  static const String appVersion = '1.0.0';

  // Accent Colors Available for Customization
  static const List<Color> accentColors = [
    Color(0xFF10B981), // Emerald Aurora
    Color(0xFF3B82F6), // Electric Cobalt
    Color(0xFF8B5CF6), // Cosmic Violet
    Color(0xFFF43F5E), // Crimson Sunset
    Color(0xFFF59E0B), // Sunset Amber
    Color(0xFF14B8A6), // Mystic Teal
    Color(0xFFEC4899), // Neon Fuchsia
  ];

  static const List<String> accentColorNames = [
    'Emerald Aurora',
    'Electric Cobalt',
    'Cosmic Violet',
    'Crimson Sunset',
    'Sunset Amber',
    'Mystic Teal',
    'Neon Fuchsia',
  ];

  // Signature Accent Gradients (Primary -> Mid -> Secondary)
  static const List<List<Color>> accentGradients = [
    [Color(0xFF10B981), Color(0xFF059669), Color(0xFF34D399)], // Emerald Aurora
    [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF60A5FA)], // Electric Cobalt
    [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFFA855F7)], // Cosmic Violet
    [Color(0xFFF43F5E), Color(0xFFE11D48), Color(0xFFFB7185)], // Crimson Sunset
    [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFFBBF24)], // Sunset Amber
    [Color(0xFF14B8A6), Color(0xFF0D9488), Color(0xFF2DD4BF)], // Mystic Teal
    [Color(0xFFEC4899), Color(0xFFD946EF), Color(0xFFF472B6)], // Neon Fuchsia
  ];

  static LinearGradient getAccentGradient(int index, {Alignment begin = Alignment.topLeft, Alignment end = Alignment.bottomRight}) {
    final idx = index.clamp(0, accentGradients.length - 1);
    return LinearGradient(
      colors: accentGradients[idx],
      begin: begin,
      end: end,
    );
  }

  // Dark Theme Palette
  static const Color darkBg = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF162032);
  static const Color darkBorder = Color(0xFF2A374A);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Palette
  static const Color lightBg = Color(0xFFF4F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Macro Gradient Palettes
  static const List<Color> proteinGradient = [Color(0xFFEF4444), Color(0xFFF87171)];
  static const List<Color> carbsGradient = [Color(0xFF3B82F6), Color(0xFF60A5FA)];
  static const List<Color> fatGradient = [Color(0xFFF59E0B), Color(0xFFFBBF24)];
  static const List<Color> waterGradient = [Color(0xFF06B6D4), Color(0xFF38BDF8)];
  static const List<Color> burnedGradient = [Color(0xFF8B5CF6), Color(0xFFA855F7)];

  // Macro Flat Colors
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
