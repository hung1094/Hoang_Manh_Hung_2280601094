import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'screens/home_screen.dart';
import 'view_models/settings_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp();

  // Khởi tạo SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Khởi tạo ViewModel + load cài đặt
  final settingsViewModel = SettingsViewModel()..init(prefs);

  runApp(
    ChangeNotifierProvider<SettingsViewModel>.value(
      value: settingsViewModel,
      child: const MyApp(),
    ),
  );
}

// MyApp – const, không nhận tham số
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appTitle,

          // ĐA NGÔN NGỮ – BẮT BUỘC PHẢI CÓ 4 DELEGATE
          locale: vm.locale,
          supportedLocales: AppConstants.supportedLocales
              .map((e) => e.locale)
              .toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            // Nếu dùng i18n: AppLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            for (var locale in supportedLocales) {
              if (locale.languageCode == deviceLocale?.languageCode) {
                return locale;
              }
            }
            return const Locale('vi');
          },

          // CHỦ ĐỀ
          theme: _buildLightTheme(vm),
          darkTheme: _buildDarkTheme(vm),
          themeMode: vm.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          home: const HomeScreen(),
        );
      },
    );
  }

  // Light Theme
  ThemeData _buildLightTheme(SettingsViewModel vm) {
    return ThemeData(
      primarySwatch: vm.themeColor,
      scaffoldBackgroundColor: AppConstants.scaffoldBackgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: vm.themeColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      cardColor: AppConstants.cardBackgroundLight,
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 16 * vm.fontScale),
        bodyMedium: TextStyle(fontSize: 14 * vm.fontScale),
        labelLarge: TextStyle(fontSize: 14 * vm.fontScale),
      ).apply(fontFamily: 'Roboto'),
      brightness: Brightness.light,
      useMaterial3: true,
    );
  }

  // Dark Theme
  ThemeData _buildDarkTheme(SettingsViewModel vm) {
    return ThemeData(
      primarySwatch: vm.themeColor,
      scaffoldBackgroundColor: AppConstants.scaffoldBackgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: vm.themeColor.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: AppConstants.cardBackgroundDark,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontSize: 16 * vm.fontScale,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * vm.fontScale,
          color: Colors.white70,
        ),
        labelLarge: TextStyle(fontSize: 14 * vm.fontScale),
      ).apply(fontFamily: 'Roboto'),
      brightness: Brightness.dark,
      useMaterial3: true,
    );
  }
}
