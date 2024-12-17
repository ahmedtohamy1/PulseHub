import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/features/projects/cubit/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/ui/widgets/grouped_projects_list.dart';

class ProjectsView extends StatelessWidget {
  final List<Project> projects;

  const ProjectsView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return projects.isNotEmpty
        ? GroupedProjectsList(projects: projects)
        : const Center(
            child: Text('No Projects Found'),
          );
  }
}
