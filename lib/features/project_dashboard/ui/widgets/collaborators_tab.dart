import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_collaborators_response_model.dart';

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

  void _showEditGroupDialog(BuildContext context, Group group) {
    final nameController = TextEditingController(text: group.name);
    bool isViewer = group.isViewer ?? false;
    bool isAnalyzer = group.isAnalyzer ?? false;
    bool isEditor = group.isEditor ?? false;
    bool isMonitor = group.isMonitor ?? false;
    bool isManager = group.isManager ?? false;
    bool isNotificationsSender = group.isNotificationsSender ?? false;
    bool isLoading = false;

    // Capture the cubit before showing dialog
    final cubit = context.read<ProjectDashboardCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (dialogContext, setState) =>
              BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
            listener: (context, state) {
              if (state is ProjectDashboardUpdateCollaboratorsSuccess) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the collaborators list
                cubit.getCollaborators(widget.projectId);
              } else if (state is ProjectDashboardUpdateCollaboratorsFailure) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update group: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: AlertDialog(
              title: const Text('Edit Group'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Group Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Permissions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Viewer'),
                      value: isViewer,
                      onChanged: isLoading
                          ? null
                          : (value) =>
                              setState(() => isViewer = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Analyzer'),
                      value: isAnalyzer,
                      onChanged: isLoading
                          ? null
                          : (value) =>
                              setState(() => isAnalyzer = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Editor'),
                      value: isEditor,
                      onChanged: isLoading
                          ? null
                          : (value) =>
                              setState(() => isEditor = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Monitor'),
                      value: isMonitor,
                      onChanged: isLoading
                          ? null
                          : (value) =>
                              setState(() => isMonitor = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Manager'),
                      value: isManager,
                      onChanged: isLoading
                          ? null
                          : (value) =>
                              setState(() => isManager = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Notifications Sender'),
                      value: isNotificationsSender,
                      onChanged: isLoading
                          ? null
                          : (value) => setState(
                              () => isNotificationsSender = value ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 80,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Group name cannot be empty'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);
                      cubit.updateCollaboratorsGroup(
                        group.groupId ?? 0,
                        widget.projectId,
                        name,
                        group.description ?? '',
                        isAnalyzer,
                        isViewer,
                        isEditor,
                        isMonitor,
                        isManager,
                        isNotificationsSender,
                      );
                    },
                    child: const Text('Save'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditCollaboratorDialog(
      BuildContext context, Member member, List<Group> allGroups) {
    final nameController = TextEditingController(
        text: '${member.firstName ?? ''} ${member.lastName ?? ''}');
    final emailController = TextEditingController(text: member.email ?? '');
    final titleController = TextEditingController(text: member.title ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Collaborator Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Assigned Groups',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...allGroups.map((group) {
                          final isAssigned = group.members
                                  ?.any((m) => m.userId == member.userId) ??
                              false;
                          return CheckboxListTile(
                            title: Text(group.name ?? ''),
                            value: isAssigned,
                            onChanged: (value) {
                              // TODO: Implement group assignment functionality
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

          return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
            listener: (context, state) {
              if (state is ProjectDashboardDeleteCollaboratorsSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the collaborators list
                context
                    .read<ProjectDashboardCubit>()
                    .getCollaborators(widget.projectId);
              } else if (state is ProjectDashboardDeleteCollaboratorsFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete group: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Groups Table
                  Column(
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
                                        onPressed: () => _showEditGroupDialog(
                                            context, group),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        onPressed: () {
                                          // Capture the cubit before showing dialog
                                          final cubit = context
                                              .read<ProjectDashboardCubit>();

                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) =>
                                                BlocProvider.value(
                                              value: cubit,
                                              child: StatefulBuilder(
                                                  builder: (context, setState) {
                                                bool isLoading = false;

                                                return BlocListener<
                                                    ProjectDashboardCubit,
                                                    ProjectDashboardState>(
                                                  listener: (context, state) {
                                                    if (state
                                                        is ProjectDashboardDeleteCollaboratorsSuccess) {
                                                      Navigator.of(
                                                              dialogContext)
                                                          .pop();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Group deleted successfully'),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                      cubit.getCollaborators(
                                                          widget.projectId);
                                                    } else if (state
                                                        is ProjectDashboardDeleteCollaboratorsFailure) {
                                                      setState(() =>
                                                          isLoading = false);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Failed to delete group: ${state.message}'),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                      cubit.getCollaborators(
                                                          widget.projectId);
                                                    }
                                                  },
                                                  child: AlertDialog(
                                                    title: const Text(
                                                        'Delete Group'),
                                                    content: Text(
                                                        'Are you sure you want to delete the group "${group.name}"?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: isLoading
                                                            ? null
                                                            : () => Navigator.of(
                                                                    dialogContext)
                                                                .pop(),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      if (isLoading)
                                                        const SizedBox(
                                                          width: 80,
                                                          child: Center(
                                                            child: SizedBox(
                                                              width: 20,
                                                              height: 20,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2),
                                                            ),
                                                          ),
                                                        )
                                                      else
                                                        TextButton(
                                                          onPressed: () {
                                                            setState(() =>
                                                                isLoading =
                                                                    true);
                                                            cubit.deleteCollaboratorsGroup(
                                                                group.groupId ??
                                                                    0);
                                                          },
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error,
                                                          ),
                                                          child: const Text(
                                                              'Delete'),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),
                                          );
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
                  const SizedBox(height: 24),
                  // Collaborators Table
                  Column(
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
                                        onPressed: () =>
                                            _showEditCollaboratorDialog(
                                          context,
                                          member,
                                          groups,
                                        ),
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
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('No data available'));
      },
    );
  }
}
