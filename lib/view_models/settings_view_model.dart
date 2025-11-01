// lib/view_models/settings_view_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class SettingsViewModel extends ChangeNotifier {
  Locale _locale = const Locale('vi');
  String _currency = 'VND';
  bool _isDarkMode = false;
  double _fontScale = 1.0;
  MaterialColor _themeColor = AppConstants.themeColors[0];

  // Getters
  Locale get locale => _locale;
  String get currency => _currency;
  bool get isDarkMode => _isDarkMode;
  double get fontScale => _fontScale;
  MaterialColor get themeColor => _themeColor;

  // Khởi tạo từ SharedPreferences
  void init(SharedPreferences prefs) {
    final savedLang = prefs.getString('locale') ?? 'vi';
    _locale = Locale(savedLang);

    _currency = prefs.getString('currency') ?? 'VND';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontScale = prefs.getDouble('fontScale') ?? 1.0;

    final colorIndex = prefs.getInt('themeColorIndex') ?? 0;
    _themeColor = AppConstants
        .themeColors[colorIndex.clamp(0, AppConstants.themeColors.length - 1)];

    // ✅ Sửa: truyền vào languageCode (String)
    try {
      FlutterLocalization.instance.translate(_locale.languageCode);
    } catch (e) {
      debugPrint('⚠️ Lỗi dịch locale: $e');
    }

    notifyListeners();
  }

  // ĐỔI NGÔN NGỮ – DỊCH NGAY LẬP TỨC
  void changeLanguage(String languageCode) {
    final locale = Locale(languageCode);
    _locale = locale;
    _save('locale', languageCode);

    // ✅ Sửa: truyền vào languageCode (String)
    try {
      FlutterLocalization.instance.translate(locale.languageCode);
    } catch (e) {
      debugPrint('⚠️ Lỗi đổi ngôn ngữ: $e');
    }

    notifyListeners();
  }

  void changeCurrency(String currency) {
    _currency = currency;
    _save('currency', currency);
    notifyListeners();
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    _save('isDarkMode', value);
    notifyListeners();
  }

  void changeFontScale(double scale) {
    _fontScale = scale.clamp(0.8, 1.5);
    _save('fontScale', _fontScale);
    notifyListeners();
  }

  void changeThemeColor(MaterialColor color) {
    _themeColor = color;
    final index = AppConstants.themeColors.indexOf(color);
    _save('themeColorIndex', index);
    notifyListeners();
  }

  // Helper: lưu bất kỳ kiểu nào
  Future<void> _save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }
}
