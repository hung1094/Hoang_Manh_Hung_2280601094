import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';
import '../constants.dart';

class SettingsCurrencyTile extends StatelessWidget {
  const SettingsCurrencyTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        return ListTile(
          leading: const Icon(Icons.currency_exchange, color: Colors.teal),
          title: const Text('Tiền tệ mặc định'),
          subtitle: Text(
            AppConstants.currencies
                .firstWhere((c) => c.code == vm.currency)
                .name,
          ),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: vm.currency,
              items: AppConstants.currencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency.code,
                  child: Text('${currency.symbol}  ${currency.code}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) vm.changeCurrency(value);
              },
            ),
          ),
        );
      },
    );
  }
}
