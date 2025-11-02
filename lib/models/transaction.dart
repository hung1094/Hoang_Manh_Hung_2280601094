import 'package:flutter/foundation.dart';

/// 🧾 Model đại diện cho một giao dịch (thu nhập / chi tiêu)
@immutable
class Transaction {
  final String id;
  final String type; // 'income' hoặc 'expense'
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  /// ✅ Tạo đối tượng từ JSON (Firebase Realtime Database)
  factory Transaction.fromJson(Map<dynamic, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'expense',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      category: json['category']?.toString() ?? 'Khác',
      note: json['note']?.toString() ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(
        json['date'] is int
            ? json['date']
            : int.tryParse(json['date'].toString()) ?? 0,
      ),
    );
  }

  /// ✅ Chuyển sang JSON để lưu Firebase
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'category': category,
    'note': note,
    'date': date.millisecondsSinceEpoch,
  };

  /// ✅ Tạo bản sao mới (immutable pattern)
  Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, type: $type, amount: $amount, category: $category, date: $date)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
