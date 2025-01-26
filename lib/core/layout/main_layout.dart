import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurvedNavigationBar(
            key: const ValueKey<String>('CurvedNavigationBar'),
            index: navigationShell.currentIndex,
            height: 50,
            backgroundColor: colorScheme.surface,
            color: colorScheme.surfaceContainerHighest,
            buttonBackgroundColor: colorScheme.primary,
            animationDuration: const Duration(milliseconds: 300),
            animationCurve: Curves.easeInOut,
            items: destinations.map((destination) {
              final isSelected = destinations.indexOf(destination) ==
                  navigationShell.currentIndex;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    destination.icon,
                    size: 24,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                  if (destination.badgeBuilder != null)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: destination.badgeBuilder!(context),
                    ),
                ],
              );
            }).toList(),
            onTap: (index) => _onDestinationSelected(context, index),
          ),
          Container(
            color: colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: destinations.map((destination) {
                final isSelected = destinations.indexOf(destination) ==
                    navigationShell.currentIndex;
                return Text(
                  destination.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
