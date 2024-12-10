import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/routing/404.dart';

class Routes {
  Routes._();
  static const String loginScreen = '/login';
  static const String forgotPasswordScreen = '/forgot-password';
  static const String homePage = '/home';
  static const String explorePage = '/explore';
  static const String settingsPage = '/settings';
  static const String profilePage = 'profile';
  static const String nestedProfilePage = '/settings/profile';
  static const settingsNamedPage = '/settings';
  //static profileNamedPage([String? name]) => '/${name ?? ':profile'}';
  static Widget errorWidget(BuildContext context, GoRouterState state) =>
      const NotFoundScreen();
}
