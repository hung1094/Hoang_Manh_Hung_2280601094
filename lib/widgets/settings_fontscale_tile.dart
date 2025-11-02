import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';

class SettingsFontScaleTile extends StatelessWidget {
  const SettingsFontScaleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsViewModel, double>(
      selector: (_, vm) => vm.fontScale,
      builder: (context, fontScale, _) {
        return ListTile(
          leading: const Icon(Icons.text_fields, color: Colors.blueGrey),
          title: const Text(
            'Cỡ chữ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: fontScale,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                activeColor: Theme.of(context).colorScheme.primary,
                label: fontScale.toStringAsFixed(1),
                onChanged: (value) =>
                    context.read<SettingsViewModel>().changeFontScale(value),
              ),
              Text(
                'Hiện tại: ${(fontScale * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
