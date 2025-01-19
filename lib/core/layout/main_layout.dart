import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/layout/destinations.dart';
import 'package:pulsehub/core/routing/routes.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('MainLayout'));

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == 0) {
      // CloudMATE button - always navigate to projects screen
      context.go(Routes.homePage);
    } else {
      // Other buttons - use normal branch navigation
      navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: navigationShell),
        bottomNavigationBar: NavigationBar(
          height: 70,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) =>
              _onDestinationSelected(context, index),
          indicatorColor: Theme.of(context).primaryColor,
          destinations: destinations
              .map((destination) => NavigationDestination(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(destination.icon),
                        if (destination.badgeBuilder != null)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: destination.badgeBuilder!(context),
                          ),
                      ],
                    ),
                    label: destination.label,
                    selectedIcon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(destination.icon, color: Colors.white),
                        if (destination.badgeBuilder != null)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: destination.badgeBuilder!(context),
                          ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
}
