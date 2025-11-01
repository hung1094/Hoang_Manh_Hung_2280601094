import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../widgets/pie_chart_widget.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final DatabaseService _dbService = DatabaseService();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  DateTime selectedDate = DateTime.now();
  String filterType = 'month';
  final Map<String, Color> _categoryColors = {};

  // Lấy màu từ SharedPreferences hoặc tạo mới
  Future<void> _loadCategoryColors() async {
    final prefs = await SharedPreferences.getInstance();
    final colors = prefs.getStringList('categoryColors') ?? [];
    for (var c in colors) {
      final parts = c.split(',');
      if (parts.length == 4) {
        _categoryColors[parts[0]] = Color.fromARGB(
          int.parse(parts[1]),
          int.parse(parts[2]),
          int.parse(parts[3]),
          int.parse(parts[4]),
        );
      }
    }
  }

  Color getCategoryColor(String category) {
    if (!_categoryColors.containsKey(category)) {
      final random = Random();
      _categoryColors[category] = Color.fromARGB(
        255,
        100 + random.nextInt(155),
        100 + random.nextInt(155),
        100 + random.nextInt(155),
      );
      _saveCategoryColors();
    }
    return _categoryColors[category]!;
  }

  Future<void> _saveCategoryColors() async {
    final prefs = await SharedPreferences.getInstance();
    final colors = _categoryColors.entries
        .map(
          (e) =>
              '${e.key},${e.value.alpha},${e.value.red},${e.value.green},${e.value.blue}',
        )
        .toList();
    await prefs.setStringList('categoryColors', colors);
  }

  // Lọc dữ liệu
  List<Transaction> _filterTransactions(List<Transaction> list) {
    if (filterType == 'month') {
      return list
          .where(
            (t) =>
                t.date.month == selectedDate.month &&
                t.date.year == selectedDate.year &&
                t.type == 'expense',
          )
          .toList();
    } else {
      return list
          .where((t) => t.date.year == selectedDate.year && t.type == 'expense')
          .toList();
    }
  }

  // Chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategoryColors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange.shade600,
        title: const Text(
          'Thống kê chi tiêu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt),
            onSelected: (value) {
              setState(() {
                filterType = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'month', child: Text('Theo tháng này')),
              PopupMenuItem(value: 'year', child: Text('Theo năm nay')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _dbService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Lỗi khi tải dữ liệu!',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allExpenses = snapshot.data!;
          final expenses = _filterTransactions(allExpenses);

          if (expenses.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có dữ liệu chi tiêu!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          Map<String, double> categoryData = {};
          for (var e in expenses) {
            categoryData.update(
              e.category,
              (value) => value + e.amount,
              ifAbsent: () => e.amount,
            );
          }

          double totalExpense = categoryData.values.fold(
            0,
            (sum, item) => sum + item,
          );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.orange.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            filterType == 'month'
                                ? 'Tổng chi tiêu tháng ${selectedDate.month}/${selectedDate.year}'
                                : 'Tổng chi tiêu năm ${selectedDate.year}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_currencyFormat.format(totalExpense)} đ',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Thêm hành động xem chi tiết
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Xem chi tiết!')),
                              );
                            },
                            child: const Text('Xem chi tiết'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: PieChartWidget(
                      data: categoryData,
                      colorBuilder: getCategoryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Chi tiết theo danh mục",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...categoryData.entries.map((entry) {
                        double percent = (entry.value / totalExpense) * 100;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.label_rounded,
                                    color: getCategoryColor(entry.key),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${percent.toStringAsFixed(1)}% - ${_currencyFormat.format(entry.value)}đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
