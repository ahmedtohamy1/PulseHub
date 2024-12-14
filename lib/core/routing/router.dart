import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/layout/main_layout.dart';
import 'package:pulsehub/core/routing/404.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/auth/cubit/auth_cubit.dart';
import 'package:pulsehub/features/auth/ui/screens/login_screen.dart';
import 'package:pulsehub/features/auth/ui/screens/otp_screen.dart';
import 'package:pulsehub/features/dics/cubit/dic_cubit.dart';
import 'package:pulsehub/features/dics/ui/dic_screen.dart';
import 'package:pulsehub/features/projects/cubit/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/ui/home_screen.dart';
import 'package:pulsehub/features/projects/ui/project_details_screen.dart';

import 'package:pulsehub/features/settings/cubit/settings_cubit.dart';
import 'package:pulsehub/features/settings/ui/profile_screen.dart';
import 'package:pulsehub/features/settings/ui/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: UserManager().user?.userId != null
      ? Routes.dicScreen
      : Routes.loginScreen,
  routes: [
    GoRoute(
      path: Routes.loginScreen,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<AuthCubit>(),
        child: LoginScreen(),
      ),
    ),
    GoRoute(
      path: Routes.otpScreen,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<AuthCubit>(),
        child: VerifyOtpScreen(),
      ),
    ),
    GoRoute(
      path: Routes.dicScreen,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<DicCubit>(),
        child: const DicScreen(),
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
              builder: (context, state) => BlocProvider(
                create: (context) => sl<ProjectsCubit>()..getProjects(),
                child: const HomeScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'project-details',
                  builder: (context, state) {
                    final projectId = state.extra  as String;
                    return BlocProvider(
                      create: (context) =>
                          sl<ProjectsCubit>()..getProject(int.parse(projectId)),
                      child: const ProjectDetailsScreen(),
                    );
                  },
                ),
              ],
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
              builder: (context, state) => BlocProvider(
                create: (context) => sl<SettingsCubit>(),
                child: const SettingsScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'profile', // Use relative path for nested routes
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
