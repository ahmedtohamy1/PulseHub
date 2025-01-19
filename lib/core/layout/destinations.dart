import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pulsehub/features/settings/cubit/settings_cubit.dart';

class Destination {
  const Destination({
    required this.label,
    required this.icon,
    this.badgeBuilder,
  });

  final String label;
  final IconData icon;
  final Widget Function(BuildContext)? badgeBuilder;
}

Widget _buildNotificationBadge(BuildContext context) {
  return BlocBuilder<SettingsCubit, SettingsState>(
    builder: (context, state) {
      if (state is GetNotificationsSuccess) {
        final notifications = state.response.notifications
                ?.where((notification) =>
                    notification.warnings?.any((warning) =>
                        warning.ticketsDetails?.isNotEmpty == true) ==
                    true)
                .toList() ??
            [];

        if (notifications.isEmpty) return const SizedBox.shrink();

        // Calculate total unseen messages
        int totalUnseen = 0;
        for (final notification in notifications) {
          for (final warning in notification.warnings ?? []) {
            for (final ticket in warning.ticketsDetails ?? []) {
              if (ticket.unseenMessages != null) {
                totalUnseen =
                    totalUnseen + int.parse(ticket.unseenMessages!.toString());
              }
            }
          }
        }

        if (totalUnseen == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(minWidth: 20),
          child: Text(
            totalUnseen > 99 ? '99+' : totalUnseen.toString(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        );
      }
      return const SizedBox.shrink();
    },
  );
}

const destinations = [
  Destination(label: 'CloudMATE', icon: Icons.cloud),
  Destination(label: 'DIC Services', icon: Icons.dashboard),
  Destination(
    label: 'Notifications',
    icon: LucideIcons.bell,
    badgeBuilder: _buildNotificationBadge,
  ),
  Destination(label: 'More', icon: Icons.menu),
];
