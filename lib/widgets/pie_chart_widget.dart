import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> data;
  final Color Function(String)? colorBuilder;
  final String? title; // Tiêu đề tùy chỉnh
  final double? centerSpaceRadius; // Bán kính khoảng trống giữa
  final double? sectionsSpace; // Khoảng cách giữa các phần
  final Duration animationDuration; // Thời gian animation
  final VoidCallback? onSectionTapped; // Callback khi chạm

  const PieChartWidget({
    super.key,
    required this.data,
    this.colorBuilder,
    this.title,
    this.centerSpaceRadius,
    this.sectionsSpace,
    this.animationDuration = const Duration(milliseconds: 500),
    this.onSectionTapped,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.data.values.fold(0.0, (sum, val) => sum + val);

    if (widget.data.isEmpty || total <= 0) {
      return Center(
        child: Text(
          'Không có dữ liệu để hiển thị!',
          style: TextStyle(color: theme.disabledColor, fontSize: 16),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    setState(() => touchedIndex = -1);
                    return;
                  }
                  setState(
                    () => touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex,
                  );
                  if (widget.onSectionTapped != null) widget.onSectionTapped!();
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: widget.sectionsSpace ?? 1,
              centerSpaceRadius: widget.centerSpaceRadius ?? 40,
              sections: _buildSections(total),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: widget.data.keys.map((label) {
            final index = widget.data.keys.toList().indexOf(label);
            final color = widget.colorBuilder != null
                ? widget.colorBuilder!(label)
                : Colors.primaries[index % Colors.primaries.length];
            final value = widget.data[label]!;
            final percent = (value / total * 100).toStringAsFixed(1);

            return GestureDetector(
              onTap: () => setState(() => touchedIndex = index),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$label ($percent%, ${_currencyFormat.format(value)}đ)',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');

  List<PieChartSectionData> _buildSections(double total) {
    final entries = widget.data.entries.toList();

    return List.generate(entries.length, (i) {
      final entry = entries[i];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 13.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black38, blurRadius: 2)];

      final color = widget.colorBuilder != null
          ? widget.colorBuilder!(entry.key)
          : Colors.primaries[i % Colors.primaries.length];

      final percent = (entry.value / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '$percent%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
        badgeWidget: isTouched
            ? Text(
                _currencyFormat.format(entry.value),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              )
            : null,
        badgePositionPercentageOffset: 0.98,
      );
    });
  }
}
