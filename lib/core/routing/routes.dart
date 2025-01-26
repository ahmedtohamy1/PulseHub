import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/routing/not_found_screen.dart';

class Routes {
  Routes._();
  static const String loginScreen = '/login';
  static const String forgotPasswordScreen = '/forgot-password';
  static const String dicScreen = '/dic';
  static const String manageUsersScreen = '/manage-users';
  static const String otpScreen = '/otp';
  static const String homePage = '/home';
  static const String settingsPage = '/settings';
  static const String profilePage = '/settings/profile';
  static const String notificationsPage = '/notifications';
  static const String sessionManagerPage = '/settings/session-manager';
  static const String projectDetailsPage = '/home/project-details/';
  static const String managePage = '/settings/manage';

  static Widget errorWidget(BuildContext context, GoRouterState state) =>
      const NotFoundScreen();
}
