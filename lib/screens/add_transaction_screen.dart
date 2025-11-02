import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _type = 'expense';
  String _category = '';

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dbService = DatabaseService();
  final _formatter = NumberFormat("#,###", "vi_VN");

  bool _isSaving = false;
  bool get _isEditing => widget.transaction != null;

  final _categories = {
    'expense': [
      {'name': 'Mua sắm', 'icon': Icons.shopping_cart},
      {'name': 'Đồ ăn', 'icon': Icons.restaurant},
      {'name': 'Điện thoại', 'icon': Icons.phone_android},
      {'name': 'Giải trí', 'icon': Icons.mic_none},
      {'name': 'Xe', 'icon': Icons.directions_car},
      {'name': 'Du lịch', 'icon': Icons.flight},
      {'name': 'Sức khỏe', 'icon': Icons.favorite},
      {'name': 'Khác', 'icon': Icons.more_horiz},
    ],
    'income': [
      {'name': 'Lương', 'icon': Icons.attach_money},
      {'name': 'Đầu tư', 'icon': Icons.trending_up},
      {'name': 'Thưởng', 'icon': Icons.card_giftcard},
      {'name': 'Khác', 'icon': Icons.more_horiz},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Nếu đang sửa, nạp dữ liệu vào form
    if (_isEditing) {
      final tx = widget.transaction!;
      _type = tx.type;
      _category = tx.category;
      _amountController.text = _formatter.format(tx.amount.toInt());
      _noteController.text = tx.note;
      Future.microtask(() => _tabController.index = _type == 'expense' ? 0 : 1);
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _type = _tabController.index == 0 ? 'expense' : 'income';
          if (!_isEditing) _category = '';
        });
      }
    });

    _amountController.addListener(_formatAmount);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// 🧮 Định dạng lại khi nhập số tiền
  void _formatAmount() {
    try {
      final text = _amountController.text.replaceAll('.', '');
      if (text.isEmpty) return;

      final number = int.tryParse(text);
      if (number == null) return;

      final newText = _formatter.format(number);
      if (newText != _amountController.text && mounted) {
        _amountController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    } catch (_) {}
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();

    final plainAmount =
        double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

    if (_category.isEmpty || plainAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Vui lòng nhập đầy đủ thông tin hợp lệ!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final newTx = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      type: _type,
      amount: plainAmount,
      category: _category,
      note: _noteController.text.trim(),
      date: widget.transaction?.date ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await _dbService.updateTransaction(newTx);
      } else {
        await _dbService.addTransaction(newTx);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? '✅ Cập nhật giao dịch thành công!'
                  : '✅ Thêm giao dịch thành công!',
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Lỗi khi lưu giao dịch!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildCategoryGrid(String type) {
    final categories = _categories[type]!;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, i) {
        final item = categories[i];
        final name = item['name'] as String;
        final icon = item['icon'] as IconData;
        final selected = _category == name;

        return GestureDetector(
          onTap: () => setState(() => _category = name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected ? Colors.yellow.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.orange : Colors.grey.shade300,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? Colors.orange : Colors.grey),
                const SizedBox(height: 4),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.orange.shade900 : Colors.black87,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Danh mục', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        _buildCategoryGrid(_type),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.monetization_on_outlined),
            labelText: 'Số tiền',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.note_alt_outlined),
            labelText: 'Ghi chú',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
            backgroundColor: Colors.yellow.shade700,
          ),
          body: SafeArea(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  indicatorColor: Colors.orange,
                  tabs: const [
                    Tab(text: 'Chi tiêu'),
                    Tab(text: 'Thu nhập'),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(child: _buildInputForm()),
                        SingleChildScrollView(child: _buildInputForm()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined),
              onPressed: _isSaving ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              label: Text(
                _isEditing ? 'Cập nhật giao dịch' : 'Lưu giao dịch',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // 🔄 Loading overlay
        if (_isSaving)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.yellow),
            ),
          ),
      ],
    );
  }
}
