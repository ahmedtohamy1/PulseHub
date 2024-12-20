import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/routing/routes.dart';
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
          return Column(
            children: [
              SizedBox(
                height: kToolbarHeight, // Use AppBar's default height
                child: Container(
                  color: Theme.of(context)
                      .primaryColor, // Set the AppBar background color
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Space title and actions
                    children: [
                      // Title Section
                      const Text(
                        'All Projects',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Actions Section
                      Row(
                        children: [
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Center(child: Text(state.message)),
            ],
          );
        }
        return const Center(child: Text('Welcome to Projects'));
      },
    );
  }
}
