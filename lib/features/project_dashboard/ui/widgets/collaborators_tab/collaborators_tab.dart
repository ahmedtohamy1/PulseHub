import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_collaborators_response_model.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/collaborators_tab/add_collaborator_dialog.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/collaborators_tab/collaborator_dialog.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/collaborators_tab/collaborators_table.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/collaborators_tab/delete_dialog.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/collaborators_tab/group_dialog.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/collaborators_tab/groups_table.dart';

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
    final cubit = context.read<ProjectDashboardCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: GroupDialog(
          title: 'Edit Group',
          initialName: group.name,
          initialDescription: group.description,
          initialIsViewer: group.isViewer ?? false,
          initialIsAnalyzer: group.isAnalyzer ?? false,
          initialIsEditor: group.isEditor ?? false,
          initialIsMonitor: group.isMonitor ?? false,
          initialIsManager: group.isManager ?? false,
          initialIsNotificationsSender: group.isNotificationsSender ?? false,
          onSave: (
            String name,
            String description,
            bool isViewer,
            bool isAnalyzer,
            bool isEditor,
            bool isMonitor,
            bool isManager,
            bool isNotificationsSender,
          ) {
            cubit.updateCollaboratorsGroup(
              group.groupId ?? 0,
              widget.projectId,
              name,
              description,
              isAnalyzer,
              isViewer,
              isEditor,
              isMonitor,
              isManager,
              isNotificationsSender,
            );
          },
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final cubit = context.read<ProjectDashboardCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: GroupDialog(
          title: 'Create Group',
          onSave: (
            String name,
            String description,
            bool isViewer,
            bool isAnalyzer,
            bool isEditor,
            bool isMonitor,
            bool isManager,
            bool isNotificationsSender,
          ) {
            cubit.createCollaboratorsGroup(
              widget.projectId,
              name,
              description,
              isAnalyzer,
              isViewer,
              isEditor,
              isMonitor,
              isManager,
              isNotificationsSender,
            );
          },
        ),
      ),
    );
  }

  void _showDeleteGroupDialog(BuildContext context, Group group) {
    final cubit = context.read<ProjectDashboardCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: DeleteConfirmationDialog(
          title: 'Delete Group',
          confirmationText: group.name ?? '',
          confirmButtonText: 'Delete',
          onConfirm: () {
            cubit.deleteCollaboratorsGroup(
              group.groupId ?? 0,
              widget.projectId,
            );
          },
        ),
      ),
    );
  }

  void _showEditCollaboratorDialog(
      BuildContext context, Member member, List<Group> allGroups) {
    final cubit = context.read<ProjectDashboardCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: CollaboratorDialog(
          member: member,
          allGroups: allGroups,
          onSave: (groupsToRemove, groupsToAdd) async {
            if (groupsToRemove.isNotEmpty) {
              await cubit.removeUserFromCollaboratorsGroup(
                groupsToRemove,
                member.userId ?? 0,
                widget.projectId,
              );
            }

            if (groupsToAdd.isNotEmpty) {
              await cubit.addUserToCollaboratorsGroup(
                groupsToAdd,
                [member.userId ?? 0],
                widget.projectId,
              );
            }
          },
        ),
      ),
    );
  }

  void _showAddCollaboratorDialog(BuildContext context, List<Group> allGroups) {
    final cubit = context.read<ProjectDashboardCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AddCollaboratorDialog(
          allGroups: allGroups,
          onAdd: (selectedGroups, selectedUsers) {
            cubit.addUserToCollaboratorsGroup(
              selectedGroups,
              selectedUsers,
              widget.projectId,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      buildWhen: (previous, current) =>
          current is ProjectDashboardGetCollaboratorsLoading ||
          current is ProjectDashboardGetCollaboratorsSuccess ||
          current is ProjectDashboardGetCollaboratorsFailure,
      builder: (context, state) {
        if (state is ProjectDashboardGetCollaboratorsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectDashboardGetCollaboratorsFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ProjectDashboardGetCollaboratorsSuccess) {
          final groups = state.getCollaboratorsResponseModel.groups ?? [];
          final allMembers = groups
              .expand((group) => group.members ?? [])
              .where((member) => member.userId != null)
              .fold<Map<int, Member>>(
                {},
                (map, member) => map..putIfAbsent(member.userId!, () => member),
              )
              .values
              .toList();

          return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
            listenWhen: (previous, current) =>
                current is ProjectDashboardDeleteCollaboratorsSuccess ||
                current is ProjectDashboardDeleteCollaboratorsFailure ||
                current is ProjectDashboardUpdateCollaboratorsSuccess ||
                current is ProjectDashboardUpdateCollaboratorsFailure ||
                current is ProjectDashboardCreateCollaboratorsGroupSuccess ||
                current is ProjectDashboardCreateCollaboratorsGroupFailure ||
                current is ProjectDashboardAddUserToCollaboratorsGroupSuccess ||
                current is ProjectDashboardAddUserToCollaboratorsGroupFailure ||
                current
                    is ProjectDashboardRemoveUserFromCollaboratorsGroupSuccess ||
                current
                    is ProjectDashboardRemoveUserFromCollaboratorsGroupFailure,
            listener: (context, state) {
              if (state is ProjectDashboardDeleteCollaboratorsSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ProjectDashboardDeleteCollaboratorsFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete group: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is ProjectDashboardUpdateCollaboratorsSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ProjectDashboardUpdateCollaboratorsFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update group: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state
                  is ProjectDashboardCreateCollaboratorsGroupSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state
                  is ProjectDashboardCreateCollaboratorsGroupFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create group: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state
                  is ProjectDashboardAddUserToCollaboratorsGroupSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state
                  is ProjectDashboardAddUserToCollaboratorsGroupFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add user: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state
                  is ProjectDashboardRemoveUserFromCollaboratorsGroupSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User removed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state
                  is ProjectDashboardRemoveUserFromCollaboratorsGroupFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove user: ${state.message}'),
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
                            onPressed: () => _showCreateGroupDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Group'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GroupsTable(
                        groups: groups,
                        onEditGroup: (group) =>
                            _showEditGroupDialog(context, group),
                        onDeleteGroup: (group) {
                          _showDeleteGroupDialog(context, group);
                        },
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
                            onPressed: () =>
                                _showAddCollaboratorDialog(context, groups),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Collaborator'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CollaboratorsTable(
                        members: allMembers,
                        onEditCollaborator: (member) =>
                            _showEditCollaboratorDialog(
                          context,
                          member,
                          groups,
                        ),
                        onDeleteCollaborator: (member) {
                          final cubit = context.read<ProjectDashboardCubit>();

                          final userGroups = groups
                              .where((group) =>
                                  group.members
                                      ?.any((m) => m.userId == member.userId) ??
                                  false)
                              .map((group) => group.groupId ?? 0)
                              .toList();

                          if (userGroups.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('User is not a member of any groups'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (dialogContext) => BlocProvider.value(
                              value: cubit,
                              child: DeleteConfirmationDialog(
                                title: 'Remove User',
                                confirmationText:
                                    '${member.firstName ?? ''} ${member.lastName ?? ''}',
                                confirmButtonText: 'Remove',
                                onConfirm: () {
                                  cubit.removeUserFromCollaboratorsGroup(
                                    userGroups,
                                    member.userId ?? 0,
                                    widget.projectId,
                                  );
                                },
                              ),
                            ),
                          );
                        },
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
