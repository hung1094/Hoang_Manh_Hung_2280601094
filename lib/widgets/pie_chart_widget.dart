import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> data;
  final Color Function(String)? colorBuilder;
  final String? title;
  final double? centerSpaceRadius;
  final double? sectionsSpace;
  final Duration animationDuration;
  final VoidCallback? onSectionTapped;

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

  // ✅ Dùng để định dạng tiền Việt Nam
  static final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');

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
                color: theme.colorScheme.onSurface,
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
                  widget.onSectionTapped?.call();
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: widget.sectionsSpace ?? 1,
              centerSpaceRadius: widget.centerSpaceRadius ?? 40,
              sections: _buildSections(total),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    final entries = widget.data.entries.toList();

    return List.generate(entries.length, (i) {
      final entry = entries[i];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 12.0;
      final radius = isTouched ? 65.0 : 50.0;
      const shadows = [Shadow(color: Colors.black38, blurRadius: 2)];

      final color = widget.colorBuilder != null
          ? widget.colorBuilder!(entry.key)
          : Colors.primaries[i % Colors.primaries.length];

      final percent = (entry.value / total * 100).toStringAsFixed(1);
      final formattedValue = _currencyFormat.format(entry.value);

      // ✅ Hiển thị phần trăm (VD: 25%)
      final title = '$percent%';

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: title,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
}
