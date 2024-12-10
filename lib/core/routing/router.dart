import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/routing/404.dart';
import 'package:pulsehub/core/routing/main_layout.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/features/auth/cubit/auth_cubit.dart';
import 'package:pulsehub/features/auth/ui/screens/login_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.loginScreen,
  routes: [
    GoRoute(
      path: Routes.loginScreen,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<AuthCubit>(),
        child: LoginScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainLayout(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homePage,
              builder: (context, state) => const NotFoundScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.explorePage,
              builder: (context, state) => const NotFoundScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settingsPage,
              builder: (context, state) => const NotFoundScreen(),
              routes: [
                GoRoute(
                    path: Routes.profilePage,
                    builder: (context, state) => const NotFoundScreen()),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
