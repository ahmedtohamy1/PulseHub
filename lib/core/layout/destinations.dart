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
      if (state is GetUnseenMessagesSuccess) {
        if (state.unseenMessages == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(minWidth: 20),
          child: Text(
            state.unseenMessages > 99 ? '99+' : state.unseenMessages.toString(),
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
  Destination(label: 'Projects', icon: LucideIcons.building2),
  Destination(label: 'Manage Users', icon: Icons.manage_accounts_outlined),
  Destination(
    label: 'Notifications',
    icon: LucideIcons.bell,
    badgeBuilder: _buildNotificationBadge,
  ),
  Destination(label: 'Profile', icon: Icons.person),
];
