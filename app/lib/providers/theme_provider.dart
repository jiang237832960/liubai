import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  Future<void> loadTheme() async {
    try {
      final settings = await DatabaseHelper.instance.getSettings();
      state = _themeModeFromString(settings.themeMode);
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(String mode) async {
    state = _themeModeFromString(mode);
  }

  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
