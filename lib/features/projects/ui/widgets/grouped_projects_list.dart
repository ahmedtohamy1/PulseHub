import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/projects/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/ui/widgets/project_card.dart';

class GroupedProjectsList extends StatefulWidget {
  final List<Project> projects;

  const GroupedProjectsList({super.key, required this.projects});

  @override
  GroupedProjectsListState createState() => GroupedProjectsListState();
}

class GroupedProjectsListState extends State<GroupedProjectsList> {
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

    // Sort owners based on the 'order' property
    owners = groupedProjects.keys.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
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
      final newOrder = owners.map((o) => o.ownerId).toList();

      // Call updateOrder from the ProjectsCubit
      context.read<ProjectsCubit>().updateOrder(newOrder);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Row as Header
        SizedBox(
          height: kToolbarHeight,
          child: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Projects',
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton.filled(
                        icon: const Icon(
                          Icons.refresh,
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

        // Grouped Projects List Below
        Expanded(
          child: BlocBuilder<ProjectsCubit, ProjectsState>(
            builder: (context, state) {
              return ReorderableListView(
                padding: const EdgeInsets.all(10),
                onReorder: _onReorder,
                buildDefaultDragHandles: false,
                children: owners.map((owner) {
                  final ownerProjects = groupedProjects[owner]!;

                  return Container(
                    key: ValueKey(owner.ownerId),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
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
                                  '${owner.name} ',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                ReorderableDragStartListener(
                                  index: owners.indexOf(owner),
                                  child: const Icon(Icons.drag_handle),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Horizontal Scrolling Projects
                        SizedBox(
                          height: 310,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: ownerProjects.length,
                            itemBuilder: (context, projectIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  width: 300,
                                  child: ProjectCard(
                                      project: ownerProjects[projectIndex]),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
