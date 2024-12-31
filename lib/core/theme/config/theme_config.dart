import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeConfig {
  static ThemeData get lightTheme {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4E833B)),
    ).copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4E833B),
        brightness: Brightness.dark,
      ),
    ).copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static SystemUiOverlayStyle systemUiOverlayStyle(bool isDarkMode) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDarkMode
          ? darkTheme.scaffoldBackgroundColor
          : lightTheme.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness:
          isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }
}
