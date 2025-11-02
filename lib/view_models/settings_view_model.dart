// lib/view_models/settings_view_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class SettingsViewModel extends ChangeNotifier {
  // ==============================
  // 🔹 BIẾN & TRẠNG THÁI
  // ==============================
  Locale _locale = const Locale('vi');
  String _currency = 'VND';
  bool _isDarkMode = false;
  double _fontScale = 1.0;
  MaterialColor _themeColor = AppConstants.themeColors.first;

  SharedPreferences? _prefs;

  // ==============================
  // 🔹 GETTERS
  // ==============================
  Locale get locale => _locale;
  String get currency => _currency;
  bool get isDarkMode => _isDarkMode;
  double get fontScale => _fontScale;
  MaterialColor get themeColor => _themeColor;

  bool get isInitialized => _prefs != null;

  // ==============================
  // 🔹 KHỞI TẠO DỮ LIỆU
  // ==============================
  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;

    _locale = Locale(prefs.getString('locale') ?? 'vi');
    _currency = prefs.getString('currency') ?? 'VND';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontScale = prefs.getDouble('fontScale') ?? 1.0;

    final colorIndex = prefs.getInt('themeColorIndex') ?? 0;
    _themeColor = AppConstants
        .themeColors[colorIndex.clamp(0, AppConstants.themeColors.length - 1)];

    // ✅ Xử lý an toàn localization
    try {
      FlutterLocalization.instance.translate(_locale.languageCode);
    } catch (e) {
      debugPrint('⚠️ Không thể khởi tạo localization: $e');
    }

    notifyListeners();
  }

  // ==============================
  // 🔹 NGÔN NGỮ
  // ==============================
  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    _savePref('locale', languageCode);

    try {
      FlutterLocalization.instance.translate(languageCode);
    } catch (e) {
      debugPrint('⚠️ Lỗi khi đổi ngôn ngữ: $e');
    }

    notifyListeners();
  }

  // ==============================
  // 🔹 TIỀN TỆ
  // ==============================
  void changeCurrency(String newCurrency) {
    if (newCurrency == _currency) return;
    _currency = newCurrency;
    _savePref('currency', newCurrency);
    notifyListeners();
  }

  // ==============================
  // 🔹 CHẾ ĐỘ GIAO DIỆN
  // ==============================
  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    _savePref('isDarkMode', isDark);
    notifyListeners();
  }

  // ==============================
  // 🔹 CỠ CHỮ
  // ==============================
  void changeFontScale(double scale) {
    final newScale = scale.clamp(0.8, 1.5);
    if (newScale == _fontScale) return;
    _fontScale = newScale;
    _savePref('fontScale', _fontScale);
    notifyListeners();
  }

  // ==============================
  // 🔹 MÀU CHỦ ĐỀ
  // ==============================
  void changeThemeColor(MaterialColor color) {
    if (color == _themeColor) return;
    _themeColor = color;
    final index = AppConstants.themeColors.indexOf(color);
    _savePref('themeColorIndex', index);
    notifyListeners();
  }

  // ==============================
  // 🔹 LƯU PREF AN TOÀN
  // ==============================
  Future<void> _savePref(String key, dynamic value) async {
    if (_prefs == null) return; // tránh lỗi nếu chưa init

    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    }
  }
}
