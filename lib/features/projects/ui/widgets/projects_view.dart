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
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Projects'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton.filled(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                context.read<ProjectsCubit>().getProjects();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton.filled(
              icon: const Icon(
                Icons.home,
                color: Colors.white,
              ),
              onPressed: () {
                context.go(Routes.dicScreen);
              },
            ),
          ),
        ],
      ),
      body: projects.isNotEmpty
          ? GroupedProjectsList(projects: projects)
          : const Center(
              child: Text('No Projects Found'),
            ),
    );
  }
}
