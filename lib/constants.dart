import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  // ====================== MÀU SẮC CHỦ ĐỀ ======================
  static const Color scaffoldBackgroundLight = Color(0xFFF5F6FA);
  static const Color scaffoldBackgroundDark = Color(0xFF121212);

  static const Color appBarBackgroundLight = Colors.amber;
  static const Color appBarBackgroundDark = Colors.amberAccent;

  static const Color incomeColor = Colors.green;
  static const Color expenseColor = Colors.red;
  static const Color cardBackgroundLight = Colors.white;
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  static const Color shadowColor = Colors.grey;
  static const Color textSecondaryLight = Colors.white70;
  static const Color textSecondaryDark = Colors.grey;

  // Màu chủ đề tùy chọn (dùng cho Settings)
  static const List<MaterialColor> themeColors = [
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  // ====================== CHUỖI VĂN BẢN ======================
  static const String appTitle = 'Sổ thu chi cá nhân';
  static const String greeting = 'Xin chào';
  static const String balanceLabel = 'Số dư hiện tại';
  static const String incomeLabel = 'Thu nhập';
  static const String expenseLabel = 'Chi tiêu';
  static const String noTransactions = 'Chưa có giao dịch nào.';
  static const String addTransactionButton = 'Thêm giao dịch ngay';
  static const String recentTransactions = 'Danh sách giao dịch gần đây';
  static const String errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  static const String settingsTitle = 'Cài đặt';
  static const String languageLabel = 'Ngôn ngữ';
  static const String currencyLabel = 'Tiền tệ mặc định';
  static const String themeLabel = 'Chủ đề màu';
  static const String darkModeLabel = 'Chế độ tối';
  static const String fontSizeLabel = 'Cỡ chữ';

  // ====================== NGÔN NGỮ HỖ TRỢ ======================
  static const List<({Locale locale, String label})> supportedLocales = [
    (locale: Locale('vi'), label: 'Tiếng Việt'),
    (locale: Locale('en'), label: 'English'),
  ];

  // ====================== TIỀN TỆ VỚI LOCALE ======================
  static const List<({String code, String symbol, String name, String locale})>
  currencies = [
    (code: 'VND', symbol: '₫', name: 'Việt Nam Đồng', locale: 'vi_VN'),
    (code: 'USD', symbol: '\$', name: 'US Dollar', locale: 'en_US'),
    (code: 'EUR', symbol: '€', name: 'Euro', locale: 'de_DE'),
    (code: 'JPY', symbol: '¥', name: 'Japanese Yen', locale: 'ja_JP'),
    (code: 'GBP', symbol: '£', name: 'British Pound', locale: 'en_GB'),
  ];

  // ====================== KÍCH THƯỚC & KHOẢNG CÁCH ======================
  static const double cardPadding = 20.0;
  static const double listItemMargin = 6.0;
  static const double shadowBlurRadius = 6.0;
  static const double cardBorderRadius = 16.0;
  static const double avatarRadius = 25.0;
  static const double iconSize = 24.0;
  static const double buttonHeight = 50.0;

  // ====================== PHÂN TRANG & GIỚI HẠN ======================
  static const int transactionsPerPage = 10;
  static const int maxRecentTransactions = 5;

  // ====================== ĐỊNH DẠNG TIỀN TỆ DÙNG INTL ======================
  static String formatCurrency(
    double amount,
    String currencyCode, [
    String? locale,
  ]) {
    final currencyInfo = currencies.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => currencies[0],
    );

    // Xác định locale (dùng từ Settings hoặc fallback)
    final effectiveLocale = locale ?? currencyInfo.locale;

    // Tạo NumberFormat
    final format = NumberFormat.currency(
      locale: effectiveLocale,
      name: currencyInfo.code,
      symbol: currencyInfo.symbol,
      decimalDigits: _getDecimalDigits(currencyCode),
    );

    // Giữ dấu “–” nếu giá trị âm, còn lại bỏ dấu “+”
    return amount < 0
        ? '-${format.format(amount.abs())}'
        : format.format(amount);
  }

  // ====================== COMPACT CURRENCY (1.2M, 1.2B...) ======================
  static String formatCurrencyCompact(
    double amount,
    String currencyCode, [
    String? locale,
  ]) {
    final currencyInfo = currencies.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => currencies[0],
    );

    final effectiveLocale = locale ?? currencyInfo.locale;

    final format = NumberFormat.compactCurrency(
      locale: effectiveLocale,
      name: currencyInfo.code,
      symbol: currencyInfo.symbol,
      decimalDigits: _getDecimalDigits(currencyCode),
    );

    // Giữ dấu “–” nếu giá trị âm, còn lại bỏ dấu “+”
    return amount < 0
        ? '-${format.format(amount.abs())}'
        : format.format(amount);
  }

  // ====================== Helper: Số chữ số thập phân ======================
  static int _getDecimalDigits(String code) {
    return ['VND', 'JPY'].contains(code) ? 0 : 2;
  }

  // ====================== LẤY MÀU THEO TRẠNG THÁI ======================
  static Color getTransactionColor(bool isIncome) =>
      isIncome ? incomeColor : expenseColor;

  // ====================== LẤY MÀU NỀN THEO CHẾ ĐỘ ======================
  static Color scaffoldBackground(bool isDark) =>
      isDark ? scaffoldBackgroundDark : scaffoldBackgroundLight;

  static Color cardBackground(bool isDark) =>
      isDark ? cardBackgroundDark : cardBackgroundLight;

  static Color textSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondaryLight;
}
