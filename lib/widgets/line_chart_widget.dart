import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class LineChartWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final String filterType; // 'month' hoặc 'year'

  const LineChartWidget({
    super.key,
    required this.transactions,
    required this.filterType,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Không có dữ liệu để hiển thị'));
    }

    // Gom nhóm chi tiêu theo ngày hoặc tháng
    Map<int, double> dataMap = {};
    for (var t in transactions) {
      int key = filterType == 'month' ? t.date.day : t.date.month;
      dataMap.update(
        key,
        (value) => value + t.amount,
        ifAbsent: () => t.amount,
      );
    }

    final sortedKeys = dataMap.keys.toList()..sort();
    final spots = sortedKeys
        .map((key) => FlSpot(key.toDouble(), dataMap[key]!))
        .toList();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    filterType == 'month'
                        ? value.toInt().toString()
                        : 'T${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.orangeAccent,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orangeAccent.withOpacity(0.3),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
