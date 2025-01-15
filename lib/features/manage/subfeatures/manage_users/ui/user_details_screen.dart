import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

class UserDetailsScreen extends StatefulWidget {
  final User user;

  const UserDetailsScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController confirmController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    confirmController.dispose();
  }

  bool navigateToManageUsers = false;

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    bool isLoading = false;
    final cubit = sl<ManageUsersCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'To confirm deletion, please type "${widget.user.firstName}"'),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                  hintText: 'Type user first name',
                ),
                autofocus: true,
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (confirmController.text == widget.user.firstName) {
                        setState(() => isLoading = true);

                        await cubit.deleteUser(widget.user.userId.toString());
                        await cubit.getAllUsers();

                        if (context.mounted) {
                          navigateToManageUsers = true;
                          context.pop();
                        }
                      }
                    },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (navigateToManageUsers) {
      context.pop();
    }

    return BlocListener<ManageUsersCubit, ManageUsersState>(
      listener: (context, state) {
        if (state is ManageUsersDeleteSuccess) {
          context.pop();
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              '${widget.user.firstName?.isNotEmpty == true ? widget.user.firstName : 'N/A'} ${widget.user.lastName?.isNotEmpty == true ? widget.user.lastName : 'N/A'}'),
          actions: [
            IconButton(
              onPressed: () {
                // TODO: Implement edit user
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => _showDeleteConfirmationDialog(context),
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
            ),
          ],
        ),
        body: BlocListener<ManageUsersCubit, ManageUsersState>(
          listener: (context, state) {
            if (state is ManageUsersDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
              );
            } else if (state is ManageUsersDeleteFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withOpacity(0.1),
                      image: widget.user.pictureUrl?.isNotEmpty == true
                          ? DecorationImage(
                              image: NetworkImage(widget.user.pictureUrl!),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {},
                            )
                          : null,
                    ),
                    child: widget.user.pictureUrl?.isNotEmpty != true
                        ? Icon(
                            Icons.person,
                            size: 80,
                            color: colorScheme.primary.withOpacity(0.5),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 32),

                // User Info
                _buildInfoCard(
                  context,
                  title: 'Email',
                  value: widget.user.email?.isNotEmpty == true
                      ? widget.user.email!
                      : 'N/A',
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  title: 'First Name',
                  value: widget.user.firstName?.isNotEmpty == true
                      ? widget.user.firstName!
                      : 'N/A',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  title: 'Last Name',
                  value: widget.user.lastName?.isNotEmpty == true
                      ? widget.user.lastName!
                      : 'N/A',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  title: 'Title',
                  value: widget.user.title?.isNotEmpty == true
                      ? widget.user.title!
                      : 'N/A',
                  icon: Icons.work,
                ),
                const SizedBox(height: 16),
                _buildStatusCard(
                  context,
                  title: 'Active',
                  value: widget.user.isActive == true,
                  icon: Icons.check_circle,
                  activeColor: Colors.green,
                  inactiveColor: Colors.red.shade600,
                ),
                const SizedBox(height: 16),
                _buildStatusCard(
                  context,
                  title: 'Staff',
                  value: widget.user.isStaff == true,
                  icon: Icons.badge,
                  activeColor: colorScheme.secondary,
                  inactiveColor: colorScheme.outline,
                ),
                const SizedBox(height: 16),
                _buildStatusCard(
                  context,
                  title: 'Superuser',
                  value: widget.user.isSuperuser == true,
                  icon: Icons.admin_panel_settings,
                  activeColor: colorScheme.primary,
                  inactiveColor: colorScheme.outline,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  title: 'Max Active Sessions',
                  value: widget.user.maxActiveSessions?.toString() ?? 'N/A',
                  icon: Icons.devices,
                  isNumber: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    bool isNumber = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFamily: isNumber ? 'monospace' : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required bool value,
    required IconData icon,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = value ? activeColor : inactiveColor;

    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        value ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        value ? 'Yes' : 'No',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
