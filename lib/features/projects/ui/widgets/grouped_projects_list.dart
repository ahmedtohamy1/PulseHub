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
      ..sort((a, b) => a.order!.compareTo(b.order!));
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Projects',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton.filled(
                onPressed: () => context.read<ProjectsCubit>().getProjects(),
                icon: const Icon(Icons.refresh),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Projects List
        Expanded(
          child: BlocBuilder<ProjectsCubit, ProjectsState>(
            builder: (context, state) {
              return ReorderableListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                onReorder: _onReorder,
                buildDefaultDragHandles: false,
                children: owners.map((owner) {
                  final ownerProjects = groupedProjects[owner]!;

                  return Container(
                    key: ValueKey(owner.ownerId),
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Owner Header
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              // Owner Logo
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: owner.logoUrl.isNotEmpty
                                      ? Image.network(
                                          owner.logoUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.business,
                                            size: 32,
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.5),
                                          ),
                                        )
                                      : Icon(
                                          Icons.business,
                                          size: 32,
                                          color: colorScheme.primary
                                              .withValues(alpha: 0.5),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Owner Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      owner.name,
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${ownerProjects.length} Projects',
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Reorder Handle
                              ReorderableDragStartListener(
                                index: owners.indexOf(owner),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Projects Horizontal List
                        SizedBox(
                          height: 400, // Increased height for bigger cards
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: ownerProjects.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: SizedBox(
                                  width:
                                      340, // Increased width for bigger cards
                                  child: ProjectCard(
                                      project: ownerProjects[index]),
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
