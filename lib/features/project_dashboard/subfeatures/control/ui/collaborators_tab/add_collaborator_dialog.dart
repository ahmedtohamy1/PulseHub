import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_collaborators_response_model.dart';

class AddCollaboratorDialog extends StatefulWidget {
  final List<Group> allGroups;
  final void Function(List<int>? selectedGroups, List<int> selectedUsers) onAdd;

  const AddCollaboratorDialog({
    super.key,
    required this.allGroups,
    required this.onAdd,
  });

  @override
  State<AddCollaboratorDialog> createState() => _AddCollaboratorDialogState();
}

class _AddCollaboratorDialogState extends State<AddCollaboratorDialog> {
  final selectedUsers = <User>{};
  final selectedGroups = <int>{};
  final searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<ProjectDashboardCubit>().getAllUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
      listenWhen: (previous, current) =>
          current is ProjectDashboardAddUserToCollaboratorsGroupSuccess ||
          current is ProjectDashboardAddUserToCollaboratorsGroupFailure,
      listener: (context, state) {
        if (state is ProjectDashboardAddUserToCollaboratorsGroupSuccess) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        } else if (state
            is ProjectDashboardAddUserToCollaboratorsGroupFailure) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add users: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
        buildWhen: (previous, current) =>
            current is ProjectDashboardAddUserToCollaboratorsGroupLoading,
        builder: (context, state) {
          final isAddLoading =
              state is ProjectDashboardAddUserToCollaboratorsGroupLoading;
          final isLoadingState = isAddLoading || isLoading;

          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Collaborators',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: searchController,
                              enabled: !isLoadingState,
                              decoration: const InputDecoration(
                                labelText: 'Search by Name or Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Type to search...',
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<ProjectDashboardCubit,
                                ProjectDashboardState>(
                              buildWhen: (previous, current) =>
                                  current is ProjectDashboardGetAllUsersLoading ||
                                  current
                                      is ProjectDashboardGetAllUsersSuccess ||
                                  current is ProjectDashboardGetAllUsersFailure,
                              builder: (context, state) {
                                if (state
                                    is ProjectDashboardGetAllUsersLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (state
                                    is ProjectDashboardGetAllUsersFailure) {
                                  return Center(
                                    child: Text('Error: ${state.message}'),
                                  );
                                }

                                if (state
                                    is ProjectDashboardGetAllUsersSuccess) {
                                  final users =
                                      state.getAllResponseModel.results.users ?? [];
                                  final searchTerm =
                                      searchController.text.toLowerCase();
                                  final filteredUsers = users.where((user) {
                                    final fullName =
                                        '${user.firstName} ${user.lastName}'
                                            .toLowerCase();
                                    final email =
                                        user.email.toLowerCase();

                                    return searchTerm.isEmpty ||
                                        fullName.contains(searchTerm) ||
                                        email.contains(searchTerm);
                                  }).toList();

                                  if (filteredUsers.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          'No users found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Select Users',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${filteredUsers.length} users found',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        height: 200,
                                        child: ListView.builder(
                                          itemCount: filteredUsers.length,
                                          itemBuilder: (context, index) {
                                            final user = filteredUsers[index];
                                            final isSelected =
                                                selectedUsers.contains(user);

                                            return CheckboxListTile(
                                              title: Text(
                                                  '${user.firstName} ${user.lastName}'),
                                              subtitle: Text(user.email),
                                              value: isSelected,
                                              onChanged: isLoadingState
                                                  ? null
                                                  : (value) {
                                                      setState(() {
                                                        if (value ?? false) {
                                                          selectedUsers
                                                              .add(user);
                                                        } else {
                                                          selectedUsers
                                                              .remove(user);
                                                        }
                                                      });
                                                    },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Select Groups',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${selectedGroups.length} selected',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.allGroups.map((group) {
                                final isSelected =
                                    selectedGroups.contains(group.groupId);
                                return FilterChip(
                                  label: Text(group.name ?? ''),
                                  selected: isSelected,
                                  onSelected: isLoadingState
                                      ? null
                                      : (value) {
                                          setState(() {
                                            if (value) {
                                              selectedGroups
                                                  .add(group.groupId ?? 0);
                                            } else {
                                              selectedGroups
                                                  .remove(group.groupId ?? 0);
                                            }
                                          });
                                        },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoadingState
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        if (isLoadingState)
                          const SizedBox(
                            width: 80,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        else
                          FilledButton(
                            onPressed: selectedUsers.isEmpty
                                ? null
                                : () {
                                    setState(() => isLoading = true);
                                    widget.onAdd(
                                      selectedGroups.isEmpty
                                          ? null
                                          : selectedGroups.toList(),
                                      selectedUsers
                                          .map((u) => u.userId)
                                          .toList(),
                                    );
                                  },
                            child: const Text('Add'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
