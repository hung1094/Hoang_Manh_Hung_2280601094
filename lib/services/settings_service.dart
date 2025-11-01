import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _themeModeKey = 'themeMode';
  static const _themeColorKey = 'themeColor';
  static const _languageKey = 'language';
  static const _currencyKey = 'currency';
  static const _fontScaleKey = 'fontScale';

  /// Lưu cài đặt vào SharedPreferences
  Future<void> saveSettings({
    required bool isDarkMode,
    required MaterialColor themeColor,
    required String language,
    required String currency,
    required double fontScale,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, isDarkMode);
    await prefs.setInt(_themeColorKey, themeColor.value);
    await prefs.setString(_languageKey, language);
    await prefs.setString(_currencyKey, currency);
    await prefs.setDouble(_fontScaleKey, fontScale);
  }

  /// Tải lại cài đặt khi khởi động
  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isDarkMode': prefs.getBool(_themeModeKey) ?? false,
      'themeColor': MaterialColor(
        prefs.getInt(_themeColorKey) ?? Colors.yellow.value,
        const <int, Color>{},
      ),
      'language': prefs.getString(_languageKey) ?? 'vi',
      'currency': prefs.getString(_currencyKey) ?? 'VND',
      'fontScale': prefs.getDouble(_fontScaleKey) ?? 1.0,
    };
  }
}
