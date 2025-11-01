import 'package:intl/intl.dart';
import '../models/transaction.dart';

/// ViewModel quản lý logic xử lý dữ liệu cho màn hình Home
class HomeScreenViewModel {
  /// Bộ định dạng tiền tệ chuẩn Việt Nam
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  // -------------------------------
  // 🧮 TÍNH TOÁN & THỐNG KÊ
  // -------------------------------

  /// ✅ Tính tổng thu nhập, chi tiêu và số dư trong **tháng hiện tại**
  Map<String, double> calculateSummary(List<Transaction> transactions) {
    final now = DateTime.now();
    double income = 0, expense = 0;

    for (final t in transactions) {
      if (t.date.year == now.year && t.date.month == now.month) {
        if (t.type == 'income') {
          income += t.amount;
        } else if (t.type == 'expense') {
          expense += t.amount;
        }
      }
    }

    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  // -------------------------------
  // 💰 ĐỊNH DẠNG DỮ LIỆU
  // -------------------------------

  /// 💰 Định dạng tiền tệ sang kiểu “#,### đ”
  String formatCurrency(double amount) => _currencyFormat.format(amount);

  /// 🗓️ Lấy chuỗi hiển thị tháng/năm hiện tại (VD: Tháng 10/2025)
  String getCurrentMonthYear() {
    final now = DateTime.now();
    return 'Tháng ${now.month}/${now.year}';
  }

  // -------------------------------
  // 📋 PHÂN TRANG & LỌC DỮ LIỆU
  // -------------------------------

  /// 📋 Lấy danh sách giao dịch cho trang hiện tại (phân trang)
  List<Transaction> getPagedTransactions(
    List<Transaction> transactions,
    int page,
    int perPage,
  ) {
    if (transactions.isEmpty) return [];

    final startIndex = page * perPage;
    if (startIndex >= transactions.length) return [];

    final endIndex = (startIndex + perPage).clamp(0, transactions.length);
    return transactions.sublist(startIndex, endIndex);
  }

  /// 🔍 Lọc danh sách giao dịch theo loại ('income' hoặc 'expense')
  List<Transaction> filterByType(List<Transaction> transactions, String type) {
    if (type.isEmpty) return transactions;
    return transactions.where((t) => t.type == type).toList();
  }

  /// 🧭 (Tùy chọn mở rộng) Lọc theo danh mục cụ thể
  List<Transaction> filterByCategory(
    List<Transaction> transactions,
    String category,
  ) {
    if (category.isEmpty) return transactions;
    return transactions.where((t) => t.category == category).toList();
  }

  /// 📅 (Tùy chọn mở rộng) Lọc theo ngày cụ thể
  List<Transaction> filterByDate(
    List<Transaction> transactions,
    DateTime date,
  ) {
    return transactions
        .where(
          (t) =>
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day,
        )
        .toList();
  }
}
