import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_collaborators_response_model.dart';

class CollaboratorDialog extends StatefulWidget {
  final Member member;
  final List<Group> allGroups;
  final Function(List<int> groupsToRemove, List<int> groupsToAdd) onSave;

  const CollaboratorDialog({
    super.key,
    required this.member,
    required this.allGroups,
    required this.onSave,
  });

  @override
  State<CollaboratorDialog> createState() => _CollaboratorDialogState();
}

class _CollaboratorDialogState extends State<CollaboratorDialog> {
  late final Map<int, bool> originalAssignedGroups;
  late final Map<int, bool> currentAssignedGroups;

  @override
  void initState() {
    super.initState();
    originalAssignedGroups = Map<int, bool>.fromEntries(
      widget.allGroups.map(
        (group) => MapEntry(
          group.groupId ?? 0,
          group.members?.any((m) => m.userId == widget.member.userId) ?? false,
        ),
      ),
    );
    currentAssignedGroups = Map<int, bool>.from(originalAssignedGroups);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
      listenWhen: (previous, current) =>
          current is ProjectDashboardAddUserToCollaboratorsGroupSuccess ||
          current is ProjectDashboardRemoveUserFromCollaboratorsGroupSuccess,
      listener: (context, state) {
        if (state is ProjectDashboardAddUserToCollaboratorsGroupSuccess ||
            state is ProjectDashboardRemoveUserFromCollaboratorsGroupSuccess) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
      },
      child: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
        buildWhen: (previous, current) =>
            current is ProjectDashboardAddUserToCollaboratorsGroupLoading ||
            current is ProjectDashboardRemoveUserFromCollaboratorsGroupLoading,
        builder: (context, state) {
          final isLoading = state
                  is ProjectDashboardAddUserToCollaboratorsGroupLoading ||
              state is ProjectDashboardRemoveUserFromCollaboratorsGroupLoading;

          return AlertDialog(
            title: Text(
                'Edit ${widget.member.firstName ?? ''} ${widget.member.lastName ?? ''}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Groups',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.allGroups.map((group) {
                    return CheckboxListTile(
                      title: Text(group.name ?? ''),
                      value: currentAssignedGroups[group.groupId] ?? false,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                currentAssignedGroups[group.groupId ?? 0] =
                                    value ?? false;
                              });
                            },
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
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
                FilledButton(
                  onPressed: () {
                    try {
                      final groupsToRemove = currentAssignedGroups.entries
                          .where((entry) =>
                              !entry.value &&
                              (originalAssignedGroups[entry.key] ?? false))
                          .map((entry) => entry.key)
                          .toList();

                      final groupsToAdd = currentAssignedGroups.entries
                          .where((entry) =>
                              entry.value &&
                              !(originalAssignedGroups[entry.key] ?? false))
                          .map((entry) => entry.key)
                          .toList();

                      if (groupsToAdd.isEmpty && groupsToRemove.isEmpty) {
                        Navigator.of(context).pop();
                        return;
                      }

                      widget.onSave(groupsToRemove, groupsToAdd);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update groups: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
            ],
          );
        },
      ),
    );
  }
}
