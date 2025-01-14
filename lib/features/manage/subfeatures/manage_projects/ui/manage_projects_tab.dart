import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/ui/projects_list.dart';

import '../cubit/manage_projects_cubit.dart';

class ManageProjectsTab extends StatelessWidget {
  const ManageProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ManageProjectsCubit>()..getAllProjects(),
      child: const ManageProjectsView(),
    );
  }
}

class ManageProjectsView extends StatelessWidget {
  const ManageProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageProjectsCubit, ManageProjectsState>(
      builder: (context, state) {
        return switch (state) {
          GetAllProjectsLoading() => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          GetAllProjectsFailure(message: final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $message',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ),
            ),
          GetAllProjectsSuccess(projects: final response) => ProjectsList(
              projects: response.projects,
            ),
          _ => const SizedBox(),
        };
      },
    );
  }
}
