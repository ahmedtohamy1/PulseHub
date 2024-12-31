import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/core/theme/cubit/theme_cubit.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/settings/cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserManager().user;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top container with user image and name
          GestureDetector(
            onTap: () {
              context.push(Routes.profilePage);
            },
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: NetworkImage(user?.pictureUrl ?? ''),
                      onBackgroundImageError: (error, stackTrace) {
                        // Show placeholder image on error
                      },
                      child: user?.pictureUrl == null
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.firstName ?? 'Guest User',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Settings card placeholder
          GestureDetector(
            onTap: () {
              context.push(Routes.sessionManagerPage);
            },
            child: const Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 30, color: Colors.grey),
                    SizedBox(width: 16),
                    Text(
                      'Session Manager',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.settings, size: 30, color: Colors.grey),
                  SizedBox(width: 16),
                  Text(
                    'Settings Placeholder',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.moon, size: 30, color: Colors.grey),
                      SizedBox(width: 16),
                      Text(
                        'Dark Mode',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  BlocBuilder<ThemeCubit, bool>(
                    builder: (context, isDarkMode) {
                      return Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
          BlocConsumer<SettingsCubit, SettingsState>(
            listener: (context, state) {
              if (state is LogoutSuccess) {
                context.go(Routes.loginScreen);
              }
              if (state is LogoutError) {
                Fluttertoast.showToast(
                    msg: 'Failed to logout, try again later.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            },
            builder: (context, state) {
              return state is LogoutLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            // Add logout button
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            context.read<SettingsCubit>().logout();
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout')),
                    );
            },
          )
        ],
      ),
    );
  }
}
