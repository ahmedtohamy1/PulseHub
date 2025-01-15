import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/get_user_projects.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

class UserProjectsScreen extends StatelessWidget {
  final User user;

  const UserProjectsScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.firstName}\'s Projects'),
      ),
      body: BlocBuilder<ManageUsersCubit, ManageUsersState>(
        builder: (context, state) {
          if (state is ManageUsersGetUserProjectsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ManageUsersGetUserProjectsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      sl<ManageUsersCubit>().getUserProjects(user.userId!);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ManageUsersGetUserProjectsSuccess) {
            if (state.response.projectsList.isEmpty) {
              return const Center(
                child: Text('No projects found'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.response.projectsList.length,
              itemBuilder: (context, index) {
                final project = state.response.projectsList[index];
                return UserProjectCard(project: project);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class UserProjectCard extends StatelessWidget {
  final ProjectsList project;

  const UserProjectCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Picture Banner
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: project.pictureUrl.isNotEmpty
                    ? Image.network(
                        project.pictureUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.primary.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.folder,
                              size: 64,
                              color: colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: colorScheme.primary.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.folder,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Project Status Indicators
              if (project.warnings > 0 || project.isFlag)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      if (project.warnings > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                project.warnings.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (project.isFlag)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Flagged',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              // Project Title
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  project.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          // Project Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  context,
                  'Start Date',
                  project.startDate != null
                      ? DateFormat('MMM dd, yyyy').format(project.startDate!)
                      : 'N/A',
                  Icons.calendar_today,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
