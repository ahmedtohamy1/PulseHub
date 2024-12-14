import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/projects/cubit/cubit/projects_cubit.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  int _activeIconIndex = 1; // Start with "dashboard" content active.

  Widget _buildHeaderIcons(BuildContext context) {
    final iconData = [
      Icons.arrow_back,
      Icons.dashboard,
      Icons.map_sharp,
      Icons.speed_outlined,
      Icons.file_copy,
    ];

    return Row(
      children: [
        // Back Arrow
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: _getTooltipMessage(0),
            child: IconButton.filled(
              onPressed: () {
                Navigator.of(context).pop(); // Navigate back for "arrow_back".
              },
              icon: Icon(iconData[0]),
            ),
          ),
        ),
        const Spacer(), // Push other icons to the right

        // Rest of the Icons
        for (int i = 1; i < iconData.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Tooltip(
              message: _getTooltipMessage(i),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _activeIconIndex = i; // Update active icon.
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _activeIconIndex == i
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    iconData[i],
                    color: _activeIconIndex == i
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

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
            _buildProjectDetails(context, project), // Dashboard content.
            const Center(child: Text('Map Content')),
            const Center(child: Text('Speed Content')),
            const Center(child: Text('File Content')),
          ];

          return Column(
            children: [
              // Header Icons
              Container(
                color: Colors.white,
                child: _buildHeaderIcons(context),
              ),
              // Content Area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: _activeIconIndex == 0
                      ? const SizedBox() // Placeholder for navigation action.
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

  Widget _buildProjectDetails(BuildContext context, dynamic project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Owner Section
          _buildSectionTitle(context, 'Project: ${project.title}'),
          const SizedBox(height: 8),
          if (project.owner != null)
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: project.owner!.logoUrl != null
                      ? NetworkImage(project.owner!.logoUrl!)
                      : null,
                  radius: 30,
                  child: project.owner!.logoUrl == null
                      ? const Icon(Icons.broken_image)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    project.owner?.name ?? 'Unknown',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            )
          else
            const Text('Owner information not available.'),
          const SizedBox(height: 24),

          // Overview Section
          _buildSectionTitle(context, 'Overview'),
          const SizedBox(height: 8),
          _buildInfoRow('Project Title:', project.title ?? 'N/A'),
          _buildInfoRow('Project Acronym:', project.acronym ?? 'N/A'),
          _buildInfoRow('Start Date:', project.startDate ?? 'N/A'),
          _buildInfoRow('Duration:', project.duration ?? 'N/A'),
          _buildInfoRow('Budget:', project.budget ?? 'N/A'),
          _buildInfoRow('Consultant:', project.consultant ?? 'N/A'),
          _buildInfoRow('Contractor:', project.contractor ?? 'N/A'),
          _buildInfoRow(
              'Construction Date:', project.constructionDate ?? 'N/A'),
          _buildInfoRow('Age of Building:', project.ageOfBuilding ?? 'N/A'),
          _buildInfoRow('Type of Building:', project.typeOfBuilding ?? 'N/A'),
          _buildInfoRow('Size of Building:', project.size ?? 'N/A'),
          _buildInfoRow('Structure:', project.structure ?? 'N/A'),
          _buildInfoRow('Building History:', project.buildingHistory ?? 'N/A'),
          _buildInfoRow('Construction Characteristics:',
              project.constructionCharacteristics ?? 'N/A'),
          _buildInfoRow('Surrounding Environment:',
              project.surroundingEnvironment ?? 'N/A'),
          _buildInfoRow('Plans and Files:', project.plansAndFiles ?? 'N/A'),
          _buildInfoRow('Description:', project.description ?? 'N/A'),
          const SizedBox(height: 24),

          // Project Settings Section
          _buildSectionTitle(context, 'Project Settings'),
          const SizedBox(height: 8),
          _buildInfoRow('Timezone:', project.timeZone ?? 'N/A'),
          _buildInfoRow(
              'Coordinate System:', project.coordinateSystem ?? 'N/A'),
          _buildInfoRow('Date Format:', project.dateFormat ?? 'N/A'),
          const SizedBox(height: 24),

          // Monitorings Section
          if (project.monitorings != null &&
              project.monitorings!.isNotEmpty) ...[
            _buildSectionTitle(context, 'Monitorings'),
            const SizedBox(height: 8),
            ...project.monitorings!.map((monitoring) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildInfoRow(
                      monitoring.monitoringName ?? 'Monitoring',
                      monitoring.monitoringCommunications ?? 'N/A'),
                )),
          ] else
            const Text('No monitorings available.'),
        ],
      ),
    );
  }

  // Helper to build section titles
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper to build rows of information
  Widget _buildInfoRow(String label, String value) {
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
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
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
