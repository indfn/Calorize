import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const _themeChannel = MethodChannel('com.calorize.app/theme');
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final profile = await DatabaseService().getUserProfile();
      if (profile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('themeMode', profile.themeMode);
        switch (profile.themeMode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
      }
    } catch (e) {
      print('Error loading theme preference: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(String mode) async {
    try {
      final profile = await DatabaseService().getUserProfile();
      if (profile != null) {
        profile.themeMode = mode;
        
        final isar = DatabaseService().isar;
        await isar.writeTxn(() async {
          await isar.userProfiles.put(profile);
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('themeMode', mode);

        switch (mode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }

        try {
          await _themeChannel.invokeMethod('setThemeMode', {'themeMode': mode});
        } catch (e) {
          print('Failed to set native theme mode: $e');
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error setting theme mode: $e');
    }
  }
}
