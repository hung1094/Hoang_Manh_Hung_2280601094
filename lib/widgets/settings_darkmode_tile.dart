import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';

class SettingsDarkModeTile extends StatelessWidget {
  const SettingsDarkModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        return SwitchListTile.adaptive(
          title: const Text('Chế độ tối'),
          subtitle: Text(vm.isDarkMode ? 'Đang bật' : 'Đang tắt'),
          value: vm.isDarkMode,
          onChanged: vm.toggleTheme,
          secondary: Icon(
            vm.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: vm.isDarkMode ? Colors.amberAccent : Colors.blueGrey,
          ),
        );
      },
    );
  }
}
