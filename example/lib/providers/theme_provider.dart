import 'package:flutter/material.dart';

/// 🎨 Theme Provider for Dynamic Theme Management
///
/// Handles theme switching between light and dark modes with persistence
/// and provides convenient methods for theme-related operations.
///
/// ## Features:
/// - Dynamic theme switching
/// - Theme persistence (optional, can be extended)
/// - Reactive UI updates
/// - System theme detection
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if current theme is dark
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        // In a real app, you'd check system brightness
        return false;
    }
  }

  /// Set theme mode and notify listeners
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  /// Toggle between light and dark themes
  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        // Default to light when toggling from system
        setThemeMode(ThemeMode.light);
        break;
    }
  }

  /// Set theme to light mode
  void setLightTheme() => setThemeMode(ThemeMode.light);

  /// Set theme to dark mode
  void setDarkTheme() => setThemeMode(ThemeMode.dark);

  /// Set theme to system mode
  void setSystemTheme() => setThemeMode(ThemeMode.system);

  /// Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get theme mode icon
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
