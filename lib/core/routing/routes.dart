import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/routing/404.dart';

class Routes {
  Routes._();
  static const String loginScreen = '/login';
  static const String forgotPasswordScreen = '/forgot-password';
  static const String dicScreen = '/dic';
  static const String otpScreen = '/otp';
  static const String homePage = '/home';
  static const String settingsPage = '/settings';
  static const String profilePage = '/settings/profile';
  static const String projectDetailsPage = '/home/project-details/';
  static const String explorePage = '/explore';

  static Widget errorWidget(BuildContext context, GoRouterState state) =>
      const NotFoundScreen();
}
