import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/ui/projects_list.dart';

import '../cubit/manage_projects_cubit.dart';

class ManageProjectsTab extends StatefulWidget {
  const ManageProjectsTab({super.key});

  @override
  State<ManageProjectsTab> createState() => _ManageProjectsTabState();
}

class _ManageProjectsTabState extends State<ManageProjectsTab>
    with AutomaticKeepAliveClientMixin {
  late final ManageProjectsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ManageProjectsCubit>();
    _cubit.getAllProjects();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _cubit,
      child: const ManageProjectsView(),
    );
  }
}

class ManageProjectsView extends StatelessWidget {
  const ManageProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageProjectsCubit, ManageProjectsState>(
      buildWhen: (previous, current) {
        // Only rebuild for project-related states
        return current is GetAllProjectsLoading ||
            current is GetAllProjectsSuccess ||
            current is GetAllProjectsFailure;
      },
      builder: (context, state) {
        return switch (state) {
          GetAllProjectsLoading() => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          GetAllProjectsFailure(error: final error) => Center(
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
                    'Error: $error',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ),
            ),
          GetAllProjectsSuccess(projects: final response) => ProjectsList(
              projects: response.results.projects,
            ),
          _ => BlocBuilder<ManageProjectsCubit, ManageProjectsState>(
              buildWhen: (previous, current) =>
                  previous is GetAllProjectsSuccess,
              builder: (context, state) {
                if (state is GetAllProjectsSuccess) {
                  return ProjectsList(
                    projects: state.projects.results.projects,
                  );
                }
                return const SizedBox();
              },
            ),
        };
      },
    );
  }
}
