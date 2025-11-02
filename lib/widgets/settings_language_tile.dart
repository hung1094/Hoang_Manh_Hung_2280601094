import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';
import '../constants.dart';

class SettingsLanguageTile extends StatelessWidget {
  const SettingsLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        final supportedLocales = AppConstants.supportedLocales;
        final currentLocale = supportedLocales
            .map((e) => e.locale)
            .firstWhere(
              (locale) => locale.languageCode == vm.locale.languageCode,
              orElse: () => supportedLocales.first.locale,
            );

        return ListTile(
          title: const Text('Ngôn ngữ'),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: currentLocale,
              items: supportedLocales
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e.locale, child: Text(e.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  vm.changeLanguage(value.languageCode);
                }
              },
              // Thêm mô tả hỗ trợ screen reader
              icon: const Icon(Icons.language),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }
}
