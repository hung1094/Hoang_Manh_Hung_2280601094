import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final _dbService = DatabaseService();
  final _currencyFormat = NumberFormat('#,###', 'vi_VN');
  bool _isProcessing = false;

  Transaction get transaction => widget.transaction;

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) await _deleteTransaction();
  }

  Future<void> _deleteTransaction() async {
    setState(() => _isProcessing = true);

    try {
      await _dbService.deleteTransaction(transaction.id);
      if (!mounted) return;

      // ✅ Thông báo trước khi pop để tránh context lỗi
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Đã xóa giao dịch')));

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('⚠️ Lỗi khi xóa: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _editTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isProcessing) return const CircularProgressIndicator();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _editTransaction,
          icon: const Icon(Icons.edit),
          label: const Text('Sửa'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _confirmDelete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Xóa'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final mainColor = isIncome ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        foregroundColor: Colors.black,
        title: const Text(
          'Chi tiết giao dịch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: _isProcessing ? 0.4 : 1,
          duration: const Duration(milliseconds: 250),
          child: AbsorbPointer(
            absorbing: _isProcessing,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 50,
                          color: mainColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isIncome ? 'Thu nhập' : 'Chi tiêu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_currencyFormat.format(transaction.amount)} đ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDetailRow(
                          Icons.category,
                          'Danh mục',
                          transaction.category,
                        ),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Ngày',
                          DateFormat(
                            'dd/MM/yyyy • HH:mm',
                          ).format(transaction.date),
                        ),
                        _buildDetailRow(
                          Icons.note_alt_outlined,
                          'Ghi chú',
                          transaction.note,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
