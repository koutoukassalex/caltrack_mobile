import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData getTheme({
    required bool isDark,
    required Color accentColor,
  }) {
    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    final Color bgColor = isDark ? AppConstants.darkBg : AppConstants.lightBg;
    final Color surfaceColor =
        isDark ? AppConstants.darkSurface : AppConstants.lightSurface;
    final Color cardColor =
        isDark ? AppConstants.darkCard : AppConstants.lightCard;
    final Color borderColor =
        isDark ? AppConstants.darkBorder : AppConstants.lightBorder;
    final Color textPrimary =
        isDark ? AppConstants.darkTextPrimary : AppConstants.lightTextPrimary;
    final Color textSecondary = isDark
        ? AppConstants.darkTextSecondary
        : AppConstants.lightTextSecondary;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accentColor,
      onPrimary: Colors.white,
      secondary: accentColor.withOpacity(0.8),
      onSecondary: Colors.white,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      background: bgColor,
      onBackground: textPrimary,
      surface: surfaceColor,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,
      cardColor: cardColor,
      dividerColor: borderColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
        labelStyle: TextStyle(color: textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Premium Card Decoration with subtle gradient & ambient lighting
  static BoxDecoration gradientCardDecoration({
    required BuildContext context,
    Color? accentGlow,
    double borderRadius = 20,
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                isSelected && accentGlow != null ? accentGlow.withOpacity(0.18) : const Color(0xFF1A2639),
                isSelected && accentGlow != null ? accentGlow.withOpacity(0.08) : const Color(0xFF131D2D),
              ]
            : [
                isSelected && accentGlow != null ? accentGlow.withOpacity(0.12) : const Color(0xFFFFFFFF),
                isSelected && accentGlow != null ? accentGlow.withOpacity(0.04) : const Color(0xFFF8FAFC),
              ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isSelected && accentGlow != null
            ? accentGlow
            : theme.dividerColor.withOpacity(isDark ? 0.35 : 0.6),
        width: isSelected ? 1.5 : 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: isSelected && accentGlow != null
              ? accentGlow.withOpacity(isDark ? 0.25 : 0.15)
              : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
          blurRadius: isSelected ? 16 : 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Signature Hero Gradient Button Decoration
  static BoxDecoration gradientButtonDecoration({
    required List<Color> gradientColors,
    double borderRadius = 16,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: gradientColors.first.withOpacity(0.38),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  /// Radiant Badge / Chip Decoration
  static BoxDecoration gradientBadgeDecoration({
    required List<Color> gradientColors,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          gradientColors.first.withOpacity(0.18),
          gradientColors.last.withOpacity(0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: gradientColors.first.withOpacity(0.4),
        width: 1,
      ),
    );
  }
}

