import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/layout/destinations.dart';
import 'package:pulsehub/core/routing/routes.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('MainLayout'));

  final StatefulNavigationShell navigationShell;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Key for controlling the CurvedNavigationBar state
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Handle navigation when a tab is tapped
  void _onDestinationSelected(int index) {
    if (index == 0) {
      // CloudMATE button - always navigate to the home page
      context.go(Routes.homePage);
    } else {
      // Other buttons - use normal branch navigation
      widget.navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(child: widget.navigationShell),
      bottomNavigationBar: SafeArea(
        bottom: true,
        top: false,
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: widget.navigationShell.currentIndex,
          backgroundColor: colorScheme.surface,
          color: colorScheme.surfaceContainerHighest,
          buttonBackgroundColor: colorScheme.secondaryContainer,
          animationDuration: const Duration(milliseconds: 300),
          animationCurve: Curves.easeInOut,
          items: destinations.map((destination) {
            return CurvedNavigationBarItem(
              child: Icon(
                destination.icon,
                size: 24,
                color: colorScheme.onSurfaceVariant,
              ),
              label: destination.label,
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
          onTap: _onDestinationSelected,
        ),
      ),
    );
  }
}
