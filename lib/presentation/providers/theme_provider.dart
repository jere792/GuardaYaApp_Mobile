import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'is_dark_mode';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_themeKey);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, state);
  }

  Future<void> setDark(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }
}
