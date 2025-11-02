import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';
import '../constants.dart';

class SettingsThemeTile extends StatelessWidget {
  const SettingsThemeTile({super.key});

  Widget _colorDot(Color color, {bool isSelected = false}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey.shade300,
          width: isSelected ? 2.5 : 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        return ListTile(
          title: const Text('Chủ đề màu'),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<MaterialColor>(
              value: vm.themeColor,
              items: AppConstants.themeColors
                  .map(
                    (color) => DropdownMenuItem(
                      value: color,
                      child: _colorDot(
                        color,
                        isSelected: vm.themeColor == color,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (color) {
                if (color != null) vm.changeThemeColor(color);
              },
              icon: const Icon(Icons.palette),
            ),
          ),
        );
      },
    );
  }
}
