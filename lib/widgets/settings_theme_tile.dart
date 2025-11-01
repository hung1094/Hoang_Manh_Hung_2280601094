import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';
import '../constants.dart';

class SettingsThemeTile extends StatelessWidget {
  const SettingsThemeTile({super.key});

  Widget _colorDot(Color color) => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade300),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SettingsViewModel>(context);
    return ListTile(
      title: const Text('Chủ đề màu'),
      trailing: DropdownButton<MaterialColor>(
        value: vm.themeColor,
        items: AppConstants.themeColors
            .map(
              (color) =>
                  DropdownMenuItem(value: color, child: _colorDot(color)),
            )
            .toList(),
        onChanged: (color) => color != null ? vm.changeThemeColor(color) : null,
        underline: const SizedBox(),
      ),
    );
  }
}
