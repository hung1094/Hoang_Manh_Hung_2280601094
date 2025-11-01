import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';
import '../constants.dart';

class SettingsCurrencyTile extends StatelessWidget {
  const SettingsCurrencyTile({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SettingsViewModel>(context);
    return ListTile(
      title: const Text('Tiền tệ mặc định'),
      trailing: DropdownButton<String>(
        value: vm.currency,
        items: AppConstants.currencies
            .map(
              (e) => DropdownMenuItem(
                value: e.code,
                child: Text('${e.name} (${e.symbol})'),
              ),
            )
            .toList(),
        onChanged: (value) => value != null ? vm.changeCurrency(value) : null,
        underline: const SizedBox(),
      ),
    );
  }
}
