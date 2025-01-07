import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';

class CollaboratorsTab extends StatefulWidget {
  final int projectId;

  const CollaboratorsTab({
    super.key,
    required this.projectId,
  });

  @override
  State<CollaboratorsTab> createState() => _CollaboratorsTabState();
}

class _CollaboratorsTabState extends State<CollaboratorsTab> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectDashboardCubit>().getCollaborators(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      builder: (context, state) {
        if (state is ProjectDashboardGetCollaboratorsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectDashboardGetCollaboratorsFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ProjectDashboardGetCollaboratorsSuccess) {
          final groups = state.getCollaboratorsResponseModel.groups ?? [];
          final allMembers =
              groups.expand((group) => group.members ?? []).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Groups Table
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Groups',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              // TODO: Implement add group functionality
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Group'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) =>
                                    Theme.of(context).colorScheme.primary),
                            columns: const [
                              DataColumn(
                                  label: Text('Group Name',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Description',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Actions',
                                      style: TextStyle(color: Colors.white))),
                            ],
                            rows: List.generate(groups.length, (index) {
                              final group = groups[index];
                              final rowColor = index % 2 == 0
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                  : Theme.of(context).colorScheme.surface;

                              return DataRow(
                                color: MaterialStateColor.resolveWith(
                                    (states) => rowColor),
                                cells: [
                                  DataCell(Text(group.name ?? '')),
                                  DataCell(Text(group.description ?? '')),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // TODO: Implement edit functionality
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          // TODO: Implement delete functionality
                                        },
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Collaborators Table
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Collaborators',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              // TODO: Implement add collaborator functionality
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Collaborator'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) =>
                                    Theme.of(context).colorScheme.primary),
                            columns: const [
                              DataColumn(
                                  label: Text('Full Name',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Email',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Title',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Actions',
                                      style: TextStyle(color: Colors.white))),
                            ],
                            rows: List.generate(allMembers.length, (index) {
                              final member = allMembers[index];
                              final rowColor = index % 2 == 0
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                  : Theme.of(context).colorScheme.surface;

                              return DataRow(
                                color: MaterialStateColor.resolveWith(
                                    (states) => rowColor),
                                cells: [
                                  DataCell(Text(
                                      '${member.firstName ?? ''} ${member.lastName ?? ''}')),
                                  DataCell(Text(member.email ?? '')),
                                  DataCell(Text(member.title ?? '')),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // TODO: Implement edit functionality
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          // TODO: Implement delete functionality
                                        },
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('No data available'));
      },
    );
  }
}
