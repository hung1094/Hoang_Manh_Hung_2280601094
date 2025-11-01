import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';

class SettingsFontScaleTile extends StatelessWidget {
  const SettingsFontScaleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SettingsViewModel>(context);
    return ListTile(
      title: const Text('Cỡ chữ'),
      subtitle: Slider(
        value: vm.fontScale,
        min: 0.8,
        max: 1.5,
        divisions: 7,
        label: vm.fontScale.toStringAsFixed(1),
        onChanged: vm.changeFontScale,
      ),
    );
  }
}
