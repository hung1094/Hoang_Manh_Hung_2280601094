import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../widgets/pie_chart_widget.dart' as app_widgets;

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  DateTime selectedDate = DateTime.now();
  String filterType = 'month';
  final Map<String, Color> _categoryColors = {};

  @override
  void initState() {
    super.initState();
    _loadCategoryColors();
  }

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

  List<Transaction> _filterTransactions(List<Transaction> list) {
    if (filterType == 'month') {
      return list
          .where(
            (t) =>
                t.type == 'income' &&
                t.date.month == selectedDate.month &&
                t.date.year == selectedDate.year,
          )
          .toList();
    } else {
      return list
          .where((t) => t.type == 'income' && t.date.year == selectedDate.year)
          .toList();
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.yellow.shade700,
        title: const Text(
          'Thu nhập',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
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

          final allTransactions = snapshot.data!;
          final incomes = _filterTransactions(allTransactions);

          if (incomes.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có dữ liệu thu nhập!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          Map<String, double> categoryData = {};
          for (var i in incomes) {
            categoryData.update(
              i.category,
              (value) => value + i.amount,
              ifAbsent: () => i.amount,
            );
          }

          double totalIncome = categoryData.values.fold(
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
                    color: Colors.yellow.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            filterType == 'month'
                                ? 'Tổng thu nhập tháng ${selectedDate.month}/${selectedDate.year}'
                                : 'Tổng thu nhập năm ${selectedDate.year}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_currencyFormat.format(totalIncome)} đ',
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
                    child: app_widgets.PieChartWidget(
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
                        double percent = (entry.value / totalIncome) * 100;
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
                                    Icons.trending_up,
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
