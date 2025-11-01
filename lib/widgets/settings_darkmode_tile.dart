import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';

class SettingsDarkModeTile extends StatelessWidget {
  const SettingsDarkModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SettingsViewModel>(context);
    return SwitchListTile(
      title: const Text('Chế độ tối'),
      value: vm.isDarkMode,
      onChanged: vm.toggleTheme,
    );
  }
}
