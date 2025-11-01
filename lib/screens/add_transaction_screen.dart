import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _type = 'expense';
  String _category = '';
  double _amount = 0;
  String _note = '';
  final DatabaseService _dbService = DatabaseService();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) _type = 'expense';
      if (_tabController.index == 1) _type = 'income';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_isSaving || _category.isEmpty || _amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final transaction = Transaction(
      id: const Uuid().v4(),
      type: _type,
      amount: _amount,
      date: DateTime.now(),
      category: _category,
      note: _note,
    );

    _dbService
        .addTransaction(transaction)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Giao dịch đã được lưu!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi khi lưu giao dịch!'),
              backgroundColor: Colors.redAccent,
            ),
          );
        })
        .whenComplete(() => setState(() => _isSaving = false));
  }

  Widget _buildAddForm(String type) {
    List<Map<String, dynamic>> categories = type == 'expense'
        ? [
            {'name': 'Mua sắm', 'icon': Icons.shopping_cart},
            {'name': 'Đồ ăn', 'icon': Icons.restaurant},
            {'name': 'Điện thoại', 'icon': Icons.phone_android},
            {'name': 'Giải trí', 'icon': Icons.mic},
            {'name': 'Xe hơi', 'icon': Icons.directions_car},
            {'name': 'Du lịch', 'icon': Icons.flight},
            {'name': 'Sức khỏe', 'icon': Icons.favorite},
            {'name': 'Khác', 'icon': Icons.more_horiz},
          ]
        : [
            {'name': 'Lương', 'icon': Icons.attach_money},
            {'name': 'Đầu tư', 'icon': Icons.trending_up},
            {'name': 'Thưởng', 'icon': Icons.card_giftcard},
            {'name': 'Khác', 'icon': Icons.more_horiz},
          ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Chọn danh mục',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = _category == categories[index]['name'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _category = categories[index]['name']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.yellow.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.yellow.shade700
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        categories[index]['icon'],
                        color: isSelected
                            ? Colors.yellow.shade800
                            : Colors.grey.shade600,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        categories[index]['name'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.black
                              : Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Số tiền',
              prefixIcon: const Icon(Icons.payments_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                setState(() => _amount = double.tryParse(value) ?? 0),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Ghi chú',
              prefixIcon: const Icon(Icons.note_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => _note = value),
          ),
          const SizedBox(height: 30),
          Center(
            child: _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _saveTransaction,
                    icon: const Icon(Icons.save_alt),
                    label: const Text(
                      'Lưu giao dịch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ✅ Thêm build UI chính
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm giao dịch'),
        backgroundColor: Colors.yellow.shade700,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.yellow.shade700,
              labelColor: Colors.black,
              tabs: const [
                Tab(text: 'Chi tiêu'),
                Tab(text: 'Thu nhập'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAddForm('expense'), _buildAddForm('income')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
