import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/ai_report/cubit/ai_report_cubit.dart';
import 'package:pulsehub/features/ai_report/ui/ai_screen.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/analyse_screen.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/control/ui/control_screen.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/monitoring/ui/monitoring_screen.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/visualise_screen.dart';
import 'package:pulsehub/features/projects/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/ui/widgets/project_details/header_icons.dart';
import 'package:pulsehub/features/projects/ui/widgets/project_details/project_details_content.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  int _activeIconIndex = 1; // Start with "dashboard" content active.

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectsCubit, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is ProjectDetailsLoaded) {
          final project = state.project;

          final List<Widget> contentPages = [
            const SizedBox(), // Placeholder for arrow_back.
            ProjectDetailsContent(project: project), // Dashboard content.
            BlocProvider(
              create: (context) =>
                  sl<ProjectDashboardCubit>()..getDashs(project.projectId!),
              child: VisualiseScreen(
                projectId: project.projectId!,
              ),
            ),
            BlocProvider(
              create: (context) => sl<ProjectDashboardCubit>(),
              child: AnalyseScreen(
                projectId: project.projectId!,
              ),
            ),
            BlocProvider(
              create: (context) => sl<AiReportCubit>(),
              child: const AiScreen(),
            ),
            BlocProvider(
              create: (context) => sl<ProjectDashboardCubit>(),
              child: MonitoringScreen(projectId: project.projectId!),
            ),
            BlocProvider(
              create: (context) => sl<ProjectDashboardCubit>(),
              child: ControlScreen(project: project),
            ),
          ];

          return Column(
            children: [
              HeaderIcons(
                activeIconIndex: _activeIconIndex,
                onIconTap: (index) {
                  setState(() {
                    _activeIconIndex = index;
                  });
                },
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: _activeIconIndex == 0
                      ? const SizedBox()
                      : contentPages[_activeIconIndex],
                ),
              ),
            ],
          );
        } else if (state is ProjectsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProjectsError) {
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text('No project details available.'));
        }
      },
    );
  }
}
