import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color? color; // Màu tùy chỉnh
  final double size; // Kích thước tùy chỉnh
  final bool isSelected; // Trạng thái chọn
  final VoidCallback? onTap; // Callback khi nhấn

  const CategoryIcon({
    super.key,
    required this.name,
    required this.icon,
    this.color,
    this.size = 60.0, // Kích thước mặc định
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor =
        color ?? (isSelected ? theme.primaryColor : theme.disabledColor);
    final backgroundColor = isSelected
        ? theme.primaryColor.withOpacity(0.1)
        : Colors.grey[200] ?? Colors.grey[200];

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: backgroundColor,
                child: Icon(icon, size: size / 2, color: effectiveColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size / 6,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
