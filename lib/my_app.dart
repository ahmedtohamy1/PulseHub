import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/routing/router.dart';
import 'package:pulsehub/core/theme/cubit/theme_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDarkMode) {
          final theme = isDarkMode ? ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4E833B),
                brightness: Brightness.dark,
              ),
            ) : ThemeData.from(
              colorScheme:
                  ColorScheme.fromSeed(seedColor: const Color(0xFF4E833B)),
            );

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: theme.scaffoldBackgroundColor,
              systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
          );

          return MaterialApp.router(
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            theme: ThemeData.from(
              colorScheme:
                  ColorScheme.fromSeed(seedColor: const Color(0xFF4E833B)),
            ),
            darkTheme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4E833B),
                brightness: Brightness.dark,
              ),
            ),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}
