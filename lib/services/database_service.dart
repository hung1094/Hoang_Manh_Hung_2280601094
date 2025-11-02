import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import '../models/transaction.dart' as app_transaction;

class DatabaseService {
  final DatabaseReference _db;
  final Logger _logger = Logger();

  DatabaseService({String path = 'transactions/default'})
    : _db = FirebaseDatabase.instance.ref().child(path);

  /// 🔄 STREAM – Lấy danh sách giao dịch realtime và hỗ trợ lọc.
  ///
  /// - [startDate] và [endDate]: Lọc theo khoảng thời gian.
  /// - [type]: Lọc theo loại giao dịch (`income` hoặc `expense`).
  /// - [limit]: Giới hạn số lượng kết quả trả về.
  Stream<List<app_transaction.Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    int? limit,
  }) {
    Query query = _db.orderByChild('date');
    if (limit != null) query = query.limitToLast(limit);

    return query.onValue.map((event) {
      final rawData = event.snapshot.value;
      if (rawData == null) return <app_transaction.Transaction>[];

      try {
        // ✅ Chấp nhận cả Map hoặc List
        final data = rawData is Map
            ? Map<String, dynamic>.from(rawData)
            : _listToMap(rawData);

        final transactions = data.values.map((e) => _parseTransaction(e)).where(
          (t) {
            final isInRange =
                (startDate == null || !t.date.isBefore(startDate)) &&
                (endDate == null || !t.date.isAfter(endDate));
            final isCorrectType = type == null || t.type == type;
            return isInRange && isCorrectType;
          },
        ).toList();

        // 🔹 Sắp xếp mới nhất lên đầu
        transactions.sort((a, b) => b.date.compareTo(a.date));

        _logger.i('✅ ${transactions.length} giao dịch được tải');
        return transactions;
      } catch (e, stack) {
        _logger.e('❌ Lỗi khi parse dữ liệu: $e', stackTrace: stack);
        return <app_transaction.Transaction>[];
      }
    });
  }

  /// ➕ Thêm giao dịch mới.
  Future<void> addTransaction(app_transaction.Transaction transaction) async {
    try {
      final id = transaction.id.isEmpty ? const Uuid().v4() : transaction.id;
      final json = transaction.toJson()..['id'] = id;
      await _db.child(id).set(json);
      _logger.i('✅ Thêm giao dịch thành công: $id');
    } catch (e, stack) {
      _logger.e('❌ Lỗi khi thêm: $e', stackTrace: stack);
      throw Exception('Không thể thêm giao dịch');
    }
  }

  /// ✏️ Cập nhật giao dịch.
  Future<void> updateTransaction(
    app_transaction.Transaction transaction,
  ) async {
    try {
      await _db.child(transaction.id).update(transaction.toJson());
      _logger.i('✅ Cập nhật: ${transaction.id}');
    } catch (e, stack) {
      _logger.e('❌ Lỗi khi cập nhật: $e', stackTrace: stack);
      throw Exception('Không thể cập nhật giao dịch');
    }
  }

  /// 🗑️ Xóa giao dịch.
  Future<void> deleteTransaction(String id) async {
    try {
      await _db.child(id).remove();
      _logger.i('🗑️ Xóa giao dịch: $id');
    } catch (e, stack) {
      _logger.e('❌ Lỗi khi xoá: $e', stackTrace: stack);
      throw Exception('Không thể xóa giao dịch');
    }
  }

  /// 🌐 Kiểm tra trạng thái kết nối Firebase.
  Future<bool> isConnected() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('.info/connected')
          .get();
      final connected = snapshot.value == true;
      _logger.i('🔌 Firebase connected: $connected');
      return connected;
    } catch (e) {
      _logger.w('⚠️ Không kiểm tra được kết nối: $e');
      return false;
    }
  }

  // -------------------------------
  // 🧩 Helper methods
  // -------------------------------

  /// Chuyển `List<dynamic>` thành `Map<String, dynamic>`
  /// (phòng khi Firebase trả về list).
  static Map<String, dynamic> _listToMap(dynamic rawData) {
    if (rawData is! List) return {};
    final Map<String, dynamic> result = {};
    for (int i = 0; i < rawData.length; i++) {
      final value = rawData[i];
      if (value != null) result[i.toString()] = value;
    }
    return result;
  }

  /// Parse JSON an toàn → trả về đối tượng `Transaction`.
  app_transaction.Transaction _parseTransaction(dynamic data) {
    try {
      return app_transaction.Transaction.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } catch (e) {
      _logger.w('⚠️ Lỗi khi parse transaction: $e');
      rethrow;
    }
  }
}
