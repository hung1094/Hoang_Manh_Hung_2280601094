import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';
import '../constants.dart';

class SettingsLanguageTile extends StatelessWidget {
  const SettingsLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SettingsViewModel>(context);

    return ListTile(
      title: const Text('Ngôn ngữ'),
      trailing: Semantics(
        label: 'Chọn ngôn ngữ',
        child: DropdownButton<Locale>(
          value: AppConstants.supportedLocales
              .map((e) => e.locale)
              .firstWhere(
                (locale) => locale.languageCode == vm.locale.languageCode,
                orElse: () => AppConstants.supportedLocales.first.locale,
              ),
          items: AppConstants.supportedLocales
              .map(
                (e) => DropdownMenuItem(value: e.locale, child: Text(e.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              vm.changeLanguage(value.languageCode); // ✅ Truyền String
            }
          },
          underline: const SizedBox(),
        ),
      ),
    );
  }
}
