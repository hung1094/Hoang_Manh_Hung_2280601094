// lib/services/settings_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class SettingsService {
  static const _keyLocale = 'locale';
  static const _keyCurrency = 'currency';
  static const _keyDarkMode = 'isDarkMode';
  static const _keyFontScale = 'fontScale';
  static const _keyThemeIndex = 'themeColorIndex';

  SharedPreferences? _prefs;

  /// ✅ Gọi 1 lần khi khởi động app
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// ✅ Lưu toàn bộ cài đặt
  Future<void> saveSettings({
    required Locale locale,
    required String currency,
    required bool isDarkMode,
    required double fontScale,
    required MaterialColor themeColor,
  }) async {
    await init();

    final colorIndex = AppConstants.themeColors
        .indexOf(themeColor)
        .clamp(0, AppConstants.themeColors.length - 1);

    await _prefs!.setString(_keyLocale, locale.languageCode);
    await _prefs!.setString(_keyCurrency, currency);
    await _prefs!.setBool(_keyDarkMode, isDarkMode);
    await _prefs!.setDouble(_keyFontScale, fontScale);
    await _prefs!.setInt(_keyThemeIndex, colorIndex);
  }

  /// ✅ Tải lại cài đặt từ SharedPreferences
  Future<Map<String, dynamic>> loadSettings() async {
    await init();

    final lang = _prefs!.getString(_keyLocale) ?? 'vi';
    final currency = _prefs!.getString(_keyCurrency) ?? 'VND';
    final isDark = _prefs!.getBool(_keyDarkMode) ?? false;
    final scale = _prefs!.getDouble(_keyFontScale) ?? 1.0;
    final colorIndex = _prefs!.getInt(_keyThemeIndex) ?? 0;

    return {
      'locale': Locale(lang),
      'currency': currency,
      'isDarkMode': isDark,
      'fontScale': scale,
      'themeColor':
          AppConstants.themeColors[colorIndex.clamp(
            0,
            AppConstants.themeColors.length - 1,
          )],
    };
  }

  /// ✅ Cập nhật từng giá trị riêng lẻ
  Future<void> updateSetting(String key, dynamic value) async {
    await init();

    if (value is String) await _prefs!.setString(key, value);
    if (value is bool) await _prefs!.setBool(key, value);
    if (value is double) await _prefs!.setDouble(key, value);
    if (value is int) await _prefs!.setInt(key, value);
  }

  /// ✅ Xóa toàn bộ cài đặt (dành cho reset)
  Future<void> resetSettings() async {
    await init();
    await _prefs!.clear();
  }
}
