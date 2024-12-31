import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false) {
    _loadTheme();
  }

  static const _themeKey = 'isDarkMode';
  final _prefs = SharedPreferences.getInstance();

  void toggleTheme() async {
    final prefs = await _prefs;
    final newState = !state;
    emit(newState);
    await prefs.setBool(_themeKey, newState);
  }

  Future<void> _loadTheme() async {
    final prefs = await _prefs;
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    emit(isDarkMode);
  }
}
