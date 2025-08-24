import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system; // Always start with system
  bool _isDarkMode = false;

  ThemeProvider() {
    // Always initialize with system theme first
    _initializeWithSystemTheme();
    _loadThemeMode();
    // Listen to system brightness changes
    WidgetsBinding.instance.addObserver(this);
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  void _initializeWithSystemTheme() {
    // Get system brightness immediately
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode = brightness == Brightness.dark;
    _updateSystemUIOverlayStyle();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey) ?? 'system';

      switch (themeModeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }

      _updateSystemTheme();
      notifyListeners();
    } catch (e) {
      // If there's an error loading preferences, keep system theme
      _themeMode = ThemeMode.system;
      _updateSystemTheme();
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    _updateSystemTheme();

    // Notify listeners immediately for instant theme change
    notifyListeners();

    // Save preference asynchronously
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString().split('.').last);
    } catch (e) {
      // Handle error silently - theme will still work for current session
      debugPrint('Error saving theme preference: $e');
    }
  }

  void _updateSystemTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        _isDarkMode = false;
        break;
      case ThemeMode.dark:
        _isDarkMode = true;
        break;
      case ThemeMode.system:
        // Get system brightness
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        _isDarkMode = brightness == Brightness.dark;
        break;
    }

    // Update system UI overlay style
    _updateSystemUIOverlayStyle();
  }

  void _updateSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: _isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _isDarkMode
            ? const Color(0xFF2A2D47) // Dark surface color
            : Colors.white,
        systemNavigationBarIconBrightness: _isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  // Convenience methods for theme switching
  Future<void> setLightTheme() => setThemeMode(ThemeMode.light);
  Future<void> setDarkTheme() => setThemeMode(ThemeMode.dark);
  Future<void> setSystemTheme() => setThemeMode(ThemeMode.system);

  // Toggle between light and dark (ignoring system)
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setDarkTheme();
    } else {
      await setLightTheme();
    }
  }

  // Force immediate theme update (useful for instant changes)
  void forceThemeUpdate() {
    _updateSystemTheme();
    notifyListeners();
  }

  // Manually check and update system theme (useful for debugging)
  void checkSystemTheme() {
    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final newIsDarkMode = brightness == Brightness.dark;
      debugPrint(
        'Manual system check - brightness: $brightness, should be dark: $newIsDarkMode, current: $_isDarkMode',
      );

      if (_isDarkMode != newIsDarkMode) {
        _isDarkMode = newIsDarkMode;
        _updateSystemUIOverlayStyle();
        notifyListeners();
        debugPrint('Manual theme update applied');
      }
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    debugPrint('Platform brightness changed, current mode: $_themeMode');

    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final newIsDarkMode = brightness == Brightness.dark;
      debugPrint(
        'System brightness: $brightness, new dark mode: $newIsDarkMode, current: $_isDarkMode',
      );

      if (_isDarkMode != newIsDarkMode) {
        _isDarkMode = newIsDarkMode;
        _updateSystemUIOverlayStyle();
        // Force multiple notifications to ensure all widgets rebuild
        notifyListeners();
        // Schedule another notification for next frame to catch any missed widgets
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        debugPrint('Theme updated to: ${_isDarkMode ? 'Dark' : 'Light'}');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Get theme mode display name for UI
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي (النظام)';
    }
  }

  // Get theme mode icon for UI
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
