import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/projects/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/ui/widgets/projects_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Header
        Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(
                'All Projects',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton.filled(
                onPressed: () => context.read<ProjectsCubit>().getProjects(),
                icon: const Icon(Icons.refresh),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: colorScheme.primary,
                ),
              ),
              IconButton.filled(
                onPressed: () => context.read<ProjectsCubit>().getProjects(),
                icon: const Icon(Icons.menu),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: BlocBuilder<ProjectsCubit, ProjectsState>(
            builder: (context, state) {
              if (state is ProjectsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProjectsLoaded) {
                return ProjectsView(projects: state.projects.projects);
              } else if (state is ProjectsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<ProjectsCubit>().getProjects(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Welcome to Projects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
