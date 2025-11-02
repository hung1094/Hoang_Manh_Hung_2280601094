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
          foregroundColor:
              ThemeData.estimateBrightnessForColor(vm.themeColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87, // ✅ Tự động đổi màu chữ
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            const Text(
              'Ngôn ngữ & Tiền tệ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            const SettingsLanguageTile(),
            const Divider(),
            const SettingsCurrencyTile(),
            const SizedBox(height: 16),

            const Text(
              'Giao diện & Hiển thị',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            const SettingsThemeTile(),
            const Divider(),
            const SettingsDarkModeTile(),
            const Divider(),
            const SettingsFontScaleTile(),
            const SizedBox(height: 24),

            // ✅ Thêm nút reset cài đặt
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Đặt lại về mặc định'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xác nhận'),
                      content: const Text(
                        'Bạn có chắc muốn đặt lại toàn bộ cài đặt không?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text('Đặt lại'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    vm.changeLanguage('vi');
                    vm.changeCurrency('VND');
                    vm.toggleTheme(false);
                    vm.changeFontScale(1.0);
                    vm.changeThemeColor(Colors.amber);
                    // Có thể thêm service.resetSettings() nếu bạn tích hợp SettingsService
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Đã đặt lại cài đặt mặc định!'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
