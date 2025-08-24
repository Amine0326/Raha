import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Night Owl inspired dark colors - warm and comfortable
  static const Color _darkBackground = Color(0xFF1E2139); // Warm dark blue-gray
  static const Color _darkSurface = Color(
    0xFF2A2D47,
  ); // Slightly lighter surface
  static const Color _darkCard = Color(0xFF323654); // Card background
  static const Color _darkPrimary = Color(
    0xFF82AAFF,
  ); // Soft blue (adapted from original)
  static const Color _darkSecondary = Color(
    0xFFC792EA,
  ); // Soft purple (adapted)
  static const Color _darkAccent = Color(0xFFFF5370); // Soft pink (adapted)
  static const Color _darkOnBackground = Color(0xFFD6DEEB); // Light text
  static const Color _darkOnSurface = Color(
    0xFFD6DEEB,
  ); // Light text on surfaces
  static const Color _darkOnPrimary = Color(0xFF011627); // Dark text on primary
  static const Color _darkDivider = Color(0xFF3A3F58); // Subtle dividers
  static const Color _darkHint = Color(0xFF7E88A3); // Hint text

  // Light theme colors (existing)
  static const Color _lightPrimary = Color(0xFF1976D2);
  static const Color _lightSecondary = Color(0xFF9C27B0);
  static const Color _lightAccent = Color(0xFFE91E63);
  static const Color _lightBackground = Color(0xFFF8F9FA);
  static const Color _lightSurface = Colors.white;

  // Gradient colors for dark theme
  static const List<Color> _darkGradientPrimary = [
    Color(0xFF82AAFF),
    Color(0xFFC792EA),
  ];

  static const List<Color> _darkGradientSecondary = [
    Color(0xFFC792EA),
    Color(0xFFFF5370),
  ];

  static const List<Color> _darkGradientAccent = [
    Color(0xFF82AAFF),
    Color(0xFFC792EA),
    Color(0xFFFF5370),
  ];

  // Light theme gradients (existing)
  static const List<Color> _lightGradientPrimary = [
    Color(0xFF1976D2),
    Color(0xFF9C27B0),
  ];

  static const List<Color> _lightGradientSecondary = [
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
  ];

  static const List<Color> _lightGradientAccent = [
    Color(0xFF1976D2),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: _lightPrimary,
      scaffoldBackgroundColor: _lightBackground,
      cardColor: _lightSurface,
      dividerColor: Colors.grey.shade300,

      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        tertiary: _lightAccent,
        surface: _lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF212121),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed,
      ),

      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: _darkPrimary,
      scaffoldBackgroundColor: _darkBackground,
      cardColor: _darkCard,
      dividerColor: _darkDivider,

      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkSecondary,
        tertiary: _darkAccent,
        surface: _darkSurface,
        onPrimary: _darkOnPrimary,
        onSecondary: _darkOnPrimary,
        onSurface: _darkOnSurface,
        outline: _darkDivider,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkOnSurface,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _darkHint,
        type: BottomNavigationBarType.fixed,
      ),

      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: _darkHint),
        hintStyle: const TextStyle(color: _darkHint),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkCard,
        contentTextStyle: const TextStyle(color: _darkOnSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _darkOnBackground),
        bodyMedium: TextStyle(color: _darkOnBackground),
        bodySmall: TextStyle(color: _darkHint),
        headlineLarge: TextStyle(color: _darkOnBackground),
        headlineMedium: TextStyle(color: _darkOnBackground),
        headlineSmall: TextStyle(color: _darkOnBackground),
        titleLarge: TextStyle(color: _darkOnBackground),
        titleMedium: TextStyle(color: _darkOnBackground),
        titleSmall: TextStyle(color: _darkOnBackground),
      ),
    );
  }

  // Gradient helpers for both themes
  static LinearGradient getPrimaryGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark ? _darkGradientPrimary : _lightGradientPrimary,
    );
  }

  static LinearGradient getSecondaryGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark ? _darkGradientSecondary : _lightGradientSecondary,
    );
  }

  static LinearGradient getAccentGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark ? _darkGradientAccent : _lightGradientAccent,
    );
  }

  // Color getters for easy access
  static Color getPrimaryColor(bool isDark) =>
      isDark ? _darkPrimary : _lightPrimary;
  static Color getSecondaryColor(bool isDark) =>
      isDark ? _darkSecondary : _lightSecondary;
  static Color getAccentColor(bool isDark) =>
      isDark ? _darkAccent : _lightAccent;
  static Color getBackgroundColor(bool isDark) =>
      isDark ? _darkBackground : _lightBackground;
  static Color getSurfaceColor(bool isDark) =>
      isDark ? _darkSurface : _lightSurface;
  static Color getCardColor(bool isDark) => isDark ? _darkCard : _lightSurface;
  static Color getOnBackgroundColor(bool isDark) =>
      isDark ? _darkOnBackground : const Color(0xFF212121);
  static Color getOnSurfaceColor(bool isDark) =>
      isDark ? _darkOnSurface : const Color(0xFF212121);
  static Color getHintColor(bool isDark) =>
      isDark ? _darkHint : const Color(0xFF757575);
  static Color getDividerColor(bool isDark) =>
      isDark ? _darkDivider : Colors.grey.shade300;
}
