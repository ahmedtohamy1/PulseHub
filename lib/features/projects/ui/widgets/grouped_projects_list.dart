import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/projects/cubit/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/ui/widgets/project_card.dart';

class GroupedProjectsList extends StatefulWidget {
  final List<Project> projects;

  const GroupedProjectsList({super.key, required this.projects});

  @override
  _GroupedProjectsListState createState() => _GroupedProjectsListState();
}

class _GroupedProjectsListState extends State<GroupedProjectsList> {
  late List<Owner> owners;
  late Map<Owner, List<Project>> groupedProjects;

  @override
  void initState() {
    super.initState();

    // Sort projects: pinned projects first
    final sortedProjects = List<Project>.from(widget.projects)
      ..sort((a, b) => (b.isFlag ? 1 : 0).compareTo(a.isFlag ? 1 : 0));

    // Group sorted projects by owner
    groupedProjects = {};
    for (var project in sortedProjects) {
      groupedProjects.putIfAbsent(project.owner, () => []).add(project);
    }

    // Initialize the list of owners
    owners = groupedProjects.keys.toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    setState(() {
      // Reorder the owners list
      final owner = owners.removeAt(oldIndex);
      owners.insert(newIndex, owner);

      // Prepare the new order of owner IDs
      final newOrder = owners.map((o) => o.ownerId.toString()).toList();

      // Print the new order for debugging
      print('New owner order: $newOrder');

      // Call updateOrder from the ProjectsCubit
      context.read<ProjectsCubit>().updateOrder(newOrder);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        return ReorderableListView(
          padding: const EdgeInsets.all(10),
          onReorder: _onReorder,
          children: owners.map((owner) {
            final ownerProjects = groupedProjects[owner]!;

            return ReorderableDragStartListener(
              key: ValueKey(owner.ownerId), // Use owner ID as the unique key
              index: owners.indexOf(owner),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Owner Header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 5),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(owner.logoUrl),
                              radius: 20,
                              onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.person),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${owner.name} (ID: ${owner.ownerId})', // Display owner name and ID
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
                              child: ProjectCard(
                                  project: ownerProjects[projectIndex]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
