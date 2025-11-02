import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'screens/home_screen.dart';
import 'view_models/settings_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Khởi tạo Firebase
  await Firebase.initializeApp();

  // 🔧 Khởi tạo SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 🧠 Tạo và khởi tạo ViewModel cài đặt
  final settingsViewModel = SettingsViewModel()..init(prefs);

  runApp(
    ChangeNotifierProvider.value(
      value: settingsViewModel,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsViewModel, _SettingsSnapshot>(
      selector: (_, vm) => _SettingsSnapshot(
        locale: vm.locale,
        isDarkMode: vm.isDarkMode,
        fontScale: vm.fontScale,
        themeColor: vm.themeColor,
      ),
      builder: (context, snapshot, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appTitle,

          // 🌍 Đa ngôn ngữ
          locale: snapshot.locale,
          supportedLocales: AppConstants.supportedLocales
              .map((e) => e.locale)
              .toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            for (final locale in supportedLocales) {
              if (locale.languageCode == deviceLocale?.languageCode) {
                return locale;
              }
            }
            return const Locale('vi');
          },

          // 🎨 Giao diện
          theme: _buildLightTheme(snapshot),
          darkTheme: _buildDarkTheme(snapshot),
          themeMode: snapshot.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          home: const HomeScreen(),
        );
      },
    );
  }

  // 🌞 Light Theme
  ThemeData _buildLightTheme(_SettingsSnapshot s) {
    return ThemeData(
      primarySwatch: s.themeColor,
      scaffoldBackgroundColor: AppConstants.scaffoldBackgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: s.themeColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      cardColor: AppConstants.cardBackgroundLight,
      textTheme: _textTheme(s.fontScale, Brightness.light),
      brightness: Brightness.light,
      useMaterial3: true,
    );
  }

  // 🌚 Dark Theme
  ThemeData _buildDarkTheme(_SettingsSnapshot s) {
    return ThemeData(
      primarySwatch: s.themeColor,
      scaffoldBackgroundColor: AppConstants.scaffoldBackgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: s.themeColor.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: AppConstants.cardBackgroundDark,
      textTheme: _textTheme(s.fontScale, Brightness.dark),
      brightness: Brightness.dark,
      useMaterial3: true,
    );
  }

  TextTheme _textTheme(double scale, Brightness mode) {
    final baseColor = mode == Brightness.dark ? Colors.white70 : Colors.black87;
    return TextTheme(
      bodyLarge: TextStyle(fontSize: 16 * scale, color: baseColor),
      bodyMedium: TextStyle(fontSize: 14 * scale, color: baseColor),
      labelLarge: TextStyle(fontSize: 14 * scale, color: baseColor),
    ).apply(fontFamily: 'Roboto');
  }
}

// 📦 Gói lại dữ liệu để giảm rebuild không cần thiết
class _SettingsSnapshot {
  final Locale locale;
  final bool isDarkMode;
  final double fontScale;
  final MaterialColor themeColor;

  const _SettingsSnapshot({
    required this.locale,
    required this.isDarkMode,
    required this.fontScale,
    required this.themeColor,
  });

  @override
  bool operator ==(Object other) =>
      other is _SettingsSnapshot &&
      locale == other.locale &&
      isDarkMode == other.isDarkMode &&
      fontScale == other.fontScale &&
      themeColor == other.themeColor;

  @override
  int get hashCode => Object.hash(locale, isDarkMode, fontScale, themeColor);
}
