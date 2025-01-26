import 'package:flutter/material.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/ui/widgets/grouped_projects_list.dart';

class ProjectsView extends StatelessWidget {
  final List<Project> projects;

  const ProjectsView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return projects.isNotEmpty
        ? GroupedProjectsList(projects: projects)
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 64,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Projects Found',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Projects will appear here once created',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
  }
}
