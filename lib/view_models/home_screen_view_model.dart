import '../models/transaction.dart';

/// ViewModel xử lý dữ liệu cho HomeScreen
class HomeScreenViewModel {
  // -------------------------------
  // 🧮 TÍNH TOÁN & THỐNG KÊ
  // -------------------------------

  /// ✅ Tính tổng thu nhập, chi tiêu, số dư trong **tháng chỉ định** (hoặc tháng hiện tại nếu null)
  Map<String, double> calculateSummary(
    List<Transaction> transactions, {
    DateTime? forMonth,
  }) {
    if (transactions.isEmpty) {
      return {'income': 0, 'expense': 0, 'balance': 0};
    }

    final now = forMonth ?? DateTime.now();
    double income = 0, expense = 0;

    for (final t in transactions) {
      if (t.date.year == now.year && t.date.month == now.month) {
        switch (t.type) {
          case 'income':
            income += t.amount;
            break;
          case 'expense':
            expense += t.amount;
            break;
        }
      }
    }

    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  /// ✅ Tính tỷ lệ chi tiêu (expense/income)
  double getExpenseRatio(List<Transaction> transactions) {
    final summary = calculateSummary(transactions);
    final income = summary['income'] ?? 0;
    final expense = summary['expense'] ?? 0;
    return income == 0 ? 0 : (expense / income).clamp(0, 1);
  }

  /// ✅ Thống kê chi tiêu theo danh mục
  Map<String, double> getCategoryDistribution(List<Transaction> transactions) {
    final Map<String, double> distribution = {};
    for (final t in transactions) {
      if (t.type == 'expense') {
        distribution[t.category] = (distribution[t.category] ?? 0) + t.amount;
      }
    }
    return distribution;
  }

  // -------------------------------
  // 📅 THÁNG HIỆN TẠI
  // -------------------------------
  String getCurrentMonthYear([DateTime? date]) {
    final now = date ?? DateTime.now();
    return "Tháng ${now.month}/${now.year}";
  }

  // -------------------------------
  // 📋 PHÂN TRANG & LỌC DỮ LIỆU
  // -------------------------------

  /// ✅ Sắp xếp giao dịch mới nhất lên đầu
  List<Transaction> sortByNewest(List<Transaction> transactions) {
    final sorted = [...transactions];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// ✅ Phân trang giao dịch
  List<Transaction> getPagedTransactions(
    List<Transaction> transactions,
    int page,
    int perPage,
  ) {
    if (transactions.isEmpty) return [];
    final sorted = sortByNewest(transactions);
    final start = page * perPage;
    if (start >= sorted.length) return [];
    final end = (start + perPage).clamp(0, sorted.length);
    return sorted.sublist(start, end);
  }

  // -------------------------------
  // 🔍 LỌC DỮ LIỆU
  // -------------------------------

  /// Lọc theo loại (income / expense)
  List<Transaction> filterByType(List<Transaction> transactions, String type) {
    if (type.isEmpty) return transactions;
    return transactions.where((t) => t.type == type).toList();
  }

  /// Lọc theo danh mục
  List<Transaction> filterByCategory(
    List<Transaction> transactions,
    String category,
  ) {
    if (category.isEmpty) return transactions;
    return transactions.where((t) => t.category == category).toList();
  }

  /// Lọc theo ngày cụ thể
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

  /// ✅ Lọc tổng hợp (loại + danh mục + ngày)
  List<Transaction> filterTransactions({
    required List<Transaction> transactions,
    String? type,
    String? category,
    DateTime? date,
  }) {
    var filtered = transactions;
    if (type != null && type.isNotEmpty) {
      filtered = filterByType(filtered, type);
    }
    if (category != null && category.isNotEmpty) {
      filtered = filterByCategory(filtered, category);
    }
    if (date != null) {
      filtered = filterByDate(filtered, date);
    }
    return filtered;
  }
}
