import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';
import '../widgets/settings_language_tile.dart';
import '../widgets/settings_currency_tile.dart';
import '../widgets/settings_theme_tile.dart';
import '../widgets/settings_darkmode_tile.dart';
import '../widgets/settings_fontscale_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Cài đặt'),
          centerTitle: true,
          backgroundColor: vm.themeColor,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            SettingsLanguageTile(),
            Divider(),
            SettingsCurrencyTile(),
            Divider(),
            SettingsThemeTile(),
            Divider(),
            SettingsDarkModeTile(),
            Divider(),
            SettingsFontScaleTile(),
          ],
        ),
      ),
    );
  }
}
