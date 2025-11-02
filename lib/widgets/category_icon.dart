import 'package:flutter/material.dart';

/// 🧩 Widget biểu tượng danh mục – dùng cho chọn loại giao dịch.
/// Tối ưu hiệu suất, hiệu ứng chọn mượt mà và dễ tái sử dụng.
class CategoryIcon extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color? color;
  final double size;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryIcon({
    super.key,
    required this.name,
    required this.icon,
    this.color,
    this.size = 60.0,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor =
        color ??
        (isSelected ? theme.colorScheme.primary : Colors.grey.shade600);
    final backgroundColor = isSelected
        ? theme.colorScheme.primary.withOpacity(0.15)
        : Colors.grey.shade100;

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: name,
        waitDuration: const Duration(milliseconds: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    )
                  else
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Icon(icon, size: size * 0.5, color: effectiveColor),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size * 0.22,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: effectiveColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
