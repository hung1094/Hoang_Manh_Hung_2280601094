import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart' as app_transaction;
import 'package:logger/logger.dart';

class DatabaseService {
  final DatabaseReference _db;
  final Logger _logger = Logger();
  final Map<String, _CacheEntry> _cache = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  DatabaseService({String path = 'transactions/default'})
    : _db = FirebaseDatabase.instance.ref().child(path);

  /// 🔄 Lấy danh sách giao dịch realtime, có thể lọc theo ngày / loại / giới hạn
  Stream<List<app_transaction.Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    int? limit,
  }) {
    final cacheKey = '$startDate-$endDate-$type-$limit';

    // 🔹 Kiểm tra cache (còn hạn)
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.time) < _cacheDuration) {
      _logger.i('📦 Dữ liệu lấy từ cache [$cacheKey]');
      return Stream.value(cached.transactions);
    }

    // 🔹 Nếu chưa có cache, lắng nghe stream từ Firebase
    return _db.onValue.map((event) {
      try {
        final rawData = event.snapshot.value;
        if (rawData == null || rawData is! Map) {
          return <app_transaction.Transaction>[];
        }

        final data = Map<String, dynamic>.from(rawData);
        final transactions = data.values
            .map((e) {
              final json = Map<String, dynamic>.from(e as Map);
              return app_transaction.Transaction.fromJson(json);
            })
            .where((t) {
              final isInRange =
                  (startDate == null || !t.date.isBefore(startDate)) &&
                  (endDate == null || !t.date.isAfter(endDate));
              final isCorrectType = type == null || t.type == type;
              return isInRange && isCorrectType;
            })
            .toList();

        // 🔹 Sắp xếp mới nhất trước
        transactions.sort((a, b) => b.date.compareTo(a.date));

        // 🔹 Giới hạn nếu cần
        final result = limit != null
            ? transactions.take(limit).toList()
            : transactions;

        // 🔹 Cập nhật cache
        _cache[cacheKey] = _CacheEntry(result);

        _logger.i('✅ Lấy ${result.length} giao dịch từ Firebase');
        return result;
      } catch (e, stack) {
        _logger.e('❌ Lỗi khi lấy giao dịch: $e', stackTrace: stack);
        return <app_transaction.Transaction>[];
      }
    });
  }

  /// ➕ Thêm giao dịch mới
  Future<void> addTransaction(app_transaction.Transaction transaction) async {
    try {
      final id = const Uuid().v4();
      final json = transaction.toJson()..['id'] = id;
      await _db.child(id).set(json);
      _clearCache();
      _logger.i('✅ Thêm giao dịch thành công: $id');
    } catch (e, stack) {
      _logger.e('❌ Lỗi khi thêm giao dịch: $e', stackTrace: stack);
      throw Exception('Không thể thêm giao dịch');
    }
  }

  /// ✏️ Cập nhật giao dịch
  Future<void> updateTransaction(
    app_transaction.Transaction transaction,
  ) async {
    try {
      final snapshot = await _db.child(transaction.id).get();
      if (!snapshot.exists) throw Exception('Giao dịch không tồn tại');
      await _db.child(transaction.id).update(transaction.toJson());
      _clearCache();
      _logger.i('✅ Cập nhật giao dịch: ${transaction.id}');
    } catch (e, stack) {
      _logger.e('❌ Lỗi khi cập nhật giao dịch: $e', stackTrace: stack);
      throw Exception('Không thể cập nhật giao dịch');
    }
  }

  /// 🗑️ Xóa giao dịch
  Future<void> deleteTransaction(String id, {VoidCallback? onConfirm}) async {
    try {
      if (onConfirm != null) onConfirm();
      await _db.child(id).remove();
      _clearCache();
      _logger.i('🗑️ Xóa giao dịch: $id');
    } catch (e, stack) {
      _logger.e('❌ Lỗi khi xóa giao dịch: $e', stackTrace: stack);
      throw Exception('Không thể xóa giao dịch');
    }
  }

  /// 🧹 Xóa toàn bộ cache
  void _clearCache() {
    _cache.clear();
    _logger.d('🧹 Đã xóa cache');
  }

  /// 🌐 Kiểm tra trạng thái kết nối Firebase
  Future<bool> isConnected() async {
    try {
      final connectedRef = FirebaseDatabase.instance.ref('.info/connected');
      final snapshot = await connectedRef.get();
      final connected = snapshot.value == true;
      _logger.i('🔌 Trạng thái kết nối Firebase: $connected');
      return connected;
    } catch (e) {
      _logger.w('⚠️ Mất kết nối Firebase: $e');
      return false;
    }
  }
}

/// 📦 Lớp hỗ trợ lưu cache
class _CacheEntry {
  final List<app_transaction.Transaction> transactions;
  final DateTime time;

  _CacheEntry(this.transactions) : time = DateTime.now();
}
