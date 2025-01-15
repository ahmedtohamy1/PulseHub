import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/user_card.dart';

class ManageUsersTab extends StatelessWidget {
  const ManageUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ManageUsersCubit>()..getAllUsers(),
      child: ManageUsersView(),
    );
  }
}

class ManageUsersView extends StatelessWidget {
  const ManageUsersView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageUsersCubit, ManageUsersState>(
      builder: (context, state) {
        if (state is ManageUsersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ManageUsersFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load users',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.error,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    sl<ManageUsersCubit>().getAllUsers();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ManageUsersSuccess) {
          if (state.response.users?.isEmpty ?? true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No users found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No users have been added yet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.response.users?.length ?? 0,
            itemBuilder: (context, index) {
              final user = state.response.users![index];
              return UserCard(user: user);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
