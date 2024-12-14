import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/projects/cubit/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/ui/widgets/projects_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProjectsLoaded) {
          return ProjectsView(projects: state.projects.projects);
        } else if (state is ProjectsError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Welcome to Projects'));
      },
    );
  }
}
