import 'package:flutter/material.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/ui/widgets/project_card.dart';

class ProjectsView extends StatelessWidget {
  final List<Project> projects;

  const ProjectsView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('All Projects'),
      ),
      body: projects.isNotEmpty
          ? GroupedProjectsList(projects: projects)
          : const Center(
              child: Text('No Projects Found'),
            ),
    );
  }
}

class GroupedProjectsList extends StatelessWidget {
  final List<Project> projects;

  const GroupedProjectsList({Key? key, required this.projects})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort projects: pinned projects first
    // Sort projects: pinned projects first
    final List<Project> sortedProjects = List.from(projects)
      ..sort((a, b) => (b.isFlag ? 1 : 0).compareTo(a.isFlag ? 1 : 0));

    // Group sorted projects by owner
    final Map<Owner, List<Project>> groupedProjects = {};
    for (var project in sortedProjects) {
      groupedProjects.putIfAbsent(project.owner, () => []).add(project);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: groupedProjects.length,
      itemBuilder: (context, index) {
        final owner = groupedProjects.keys.elementAt(index);
        final ownerProjects = groupedProjects[owner]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Owner Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(owner.logoUrl),
                    radius: 20,
                    onBackgroundImageError: (_, __) => const Icon(Icons.person),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    owner.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Scrolling Projects
            SizedBox(
              height: 230, // Height for the horizontal scrollable row
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ownerProjects.length,
                itemBuilder: (context, projectIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 300, // Width of each project card
                      child: ProjectCard(project: ownerProjects[projectIndex]),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10), // Spacing between owner groups
          ],
        );
      },
    );
  }
}
