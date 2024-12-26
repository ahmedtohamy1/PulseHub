import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/ai_report/cubit/ai_report_cubit.dart';
import 'package:pulsehub/features/ai_report/ui/ai_screen.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/ui/screens/analyse_screen.dart';
import 'package:pulsehub/features/project_dashboard/ui/screens/visualise_screen.dart';
import 'package:pulsehub/features/projects/cubit/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

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
              child: const VisualiseScreen(),
            ),
            BlocProvider(
              create: (context) =>
                  sl<ProjectDashboardCubit>()..getDashs(project.projectId!),
              child: const AnalyseScreen(),
            ),
            BlocProvider(
              create: (context) => sl<AiReportCubit>(),
              child: const AiScreen(),
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

// HeaderIcons Widget
class HeaderIcons extends StatelessWidget {
  final int activeIconIndex;
  final Function(int) onIconTap;

  const HeaderIcons({
    required this.activeIconIndex,
    required this.onIconTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = [
      Icons.arrow_back_ios_new_outlined,
      LucideIcons.layoutGrid,
      Icons.map_sharp,
      LucideIcons.gauge,
      LucideIcons.fileText,
    ];

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: _getTooltipMessage(0),
            child: IconButton.filled(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                iconData[0],
              ),
            ),
          ),
        ),
        const Spacer(),
        for (int i = 1; i < iconData.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Tooltip(
              message: _getTooltipMessage(i),
              child: InkWell(
                onTap: () => onIconTap(i),
                child: CircleIcon(
                  icon: iconData[i],
                  isActive: activeIconIndex == i,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getTooltipMessage(int index) {
    switch (index) {
      case 0:
        return 'Back';
      case 1:
        return 'Dashboard';
      case 2:
        return 'Map';
      case 3:
        return 'Speed';
      case 4:
        return 'File Content';
      default:
        return '';
    }
  }
}

// CircleIcon Widget
class CircleIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const CircleIcon({
    required this.icon,
    required this.isActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.white,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(10.0),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Theme.of(context).primaryColor,
      ),
    );
  }
}

// ProjectDetailsContent Widget
class ProjectDetailsContent extends StatelessWidget {
  final dynamic project;

  const ProjectDetailsContent({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SectionTitle(title: 'Project: ${project.title}'),
          const SizedBox(height: 8),
          if (project.owner != null)
            ProjectOwner(owner: project.owner)
          else
            const Text('Owner information not available.'),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Overview'),
          const SizedBox(height: 8),
          ProjectOverview(project: project),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Project Settings'),
          const SizedBox(height: 8),
          ProjectSettings(project: project),
        ],
      ),
    );
  }
}

// ProjectOwner Widget
class ProjectOwner extends StatelessWidget {
  final dynamic owner;

  const ProjectOwner({required this.owner, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage:
              owner.logoUrl != null ? NetworkImage(owner.logoUrl!) : null,
          radius: 30,
          child: owner.logoUrl == null ? const Icon(Icons.broken_image) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            owner.name ?? 'Unknown',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

// ProjectOverview Widget
class ProjectOverview extends StatelessWidget {
  final Project project;

  const ProjectOverview({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoRow(label: 'Project Title:', value: project.title ?? 'N/A'),
        InfoRow(label: 'Project Acronym:', value: project.acronym ?? 'N/A'),
        InfoRow(label: 'Start Date:', value: project.startDate ?? 'N/A'),
        InfoRow(label: 'Duration:', value: project.duration ?? 'N/A'),
        InfoRow(label: 'Time Zone:', value: project.timeZone ?? 'N/A'),
        InfoRow(label: 'Budget:', value: project.budget ?? 'N/A'),
        InfoRow(label: 'Consultant:', value: project.consultant ?? 'N/A'),
        InfoRow(label: 'Contractor:', value: project.contractor ?? 'N/A'),
        InfoRow(
            label: 'Contraction Date:',
            value: project.constructionDate ?? 'N/A'),
        InfoRow(
            label: 'Age of building:', value: project.ageOfBuilding ?? 'N/A'),
        InfoRow(
            label: 'Type of building:', value: project.typeOfBuilding ?? 'N/A'),
        InfoRow(label: 'Size of building:', value: project.size ?? 'N/A'),
        InfoRow(label: 'Structure:', value: project.structure ?? 'N/A'),
        InfoRow(
            label: 'Building History:',
            value: project.buildingHistory ?? 'N/A'),
        InfoRow(
            label: 'Consturtion Characteristics:',
            value: project.constructionCharacteristics ?? 'N/A'),
        InfoRow(
            label: 'Plans and files:', value: project.plansAndFiles ?? 'N/A'),
        InfoRow(label: 'Description:', value: project.description ?? 'N/A'),
      ],
    );
  }
}

// ProjectSettings Widget
class ProjectSettings extends StatelessWidget {
  final dynamic project;

  const ProjectSettings({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoRow(label: 'Timezone:', value: project.timeZone ?? 'N/A'),
        InfoRow(
            label: 'Coordinate System:',
            value: project.coordinateSystem ?? 'N/A'),
        InfoRow(label: 'Date Format:', value: project.dateFormat ?? 'N/A'),
      ],
    );
  }
}

// InfoRow Widget
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}

// SectionTitle Widget
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
