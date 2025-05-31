import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:mobilizer/common/common/sharepreference.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  ThemeData getTheme() {
    return _isDarkMode ? darkTheme : lightTheme;
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    _updateSystemUiOverlay();
    notifyListeners();
    await AppSharedPreferences.setValue(key: 'isDarkMode', value: _isDarkMode.toString());
  }

  Future<void> _loadThemePreference() async {
    String? darkModePref = await AppSharedPreferences.getValue(key: 'isDarkMode');
    if (darkModePref != null) {
      _isDarkMode = darkModePref == 'true';
    }
    _updateSystemUiOverlay();
    notifyListeners();
  }

  void _updateSystemUiOverlay() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      statusBarBrightness: _isDarkMode ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    cardColor: Colors.white,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.all(Colors.grey),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.white),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData( // Add this
      thumbColor: WidgetStateProperty.all(Colors.grey[400]), // Subtle gray for light mode
      thickness: WidgetStateProperty.all(6.0), // Slightly thicker for visibility
      radius: const Radius.circular(3.0), // Rounded edges
      thumbVisibility: WidgetStateProperty.all(true), // Always visible when scrolling
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.white,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
      bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
      titleLarge: TextStyle(
        color: Color(0xFFE0E0E0),
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
    cardColor: const Color(0xFF1E1E1E),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.all(Colors.grey),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xFF1E1E1E)),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData( // Add this
      thumbColor: WidgetStateProperty.all(const Color(0xFF616161)), // Subtle gray for dark mode
      thickness: WidgetStateProperty.all(6.0), // Slightly thicker for visibility
      radius: const Radius.circular(3.0), // Rounded edges
      thumbVisibility: WidgetStateProperty.all(true), // Always visible when scrolling
    ),
  );
}