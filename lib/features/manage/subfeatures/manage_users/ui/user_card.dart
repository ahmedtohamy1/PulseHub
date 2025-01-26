import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/user_details_screen.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

class UserCard extends StatefulWidget {
  final User user;
  final bool? isDic;

  const UserCard({
    super.key,
    required this.user,
    this.isDic,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  final TextEditingController confirmController = TextEditingController();

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    bool isLoading = false;
    final cubit = context.read<ManageUsersCubit>();

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
                        cubit.getAllUsers();
                        if (context.mounted) {
                          Navigator.of(context).pop();
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

    return BlocListener<ManageUsersCubit, ManageUsersState>(
      listener: (context, state) {
        if (state is ManageUsersDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully')),
          );
          context.read<ManageUsersCubit>().getAllUsers();
        } else if (state is ManageUsersDeleteFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          final cubit = context.read<ManageUsersCubit>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => cubit,
                child: UserDetailsScreen(
                  user: widget.user,
                  isDic: widget.isDic,
                ),
              ),
            ),
          );
        },
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // User Picture Banner
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.user.isSuperuser == true
                            ? colorScheme.primary.withValues(alpha: 0.05)
                            : widget.user.isStaff == true
                                ? colorScheme.tertiary.withValues(alpha: 0.05)
                                : colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      child: widget.user.pictureUrl?.isNotEmpty == true
                          ? Image.network(
                              widget.user.pictureUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Icon(
                                  Icons.person,
                                  size: 64,
                                  color: widget.user.isSuperuser == true
                                      ? colorScheme.primary
                                          .withValues(alpha: 0.5)
                                      : widget.user.isStaff == true
                                          ? colorScheme.tertiary
                                              .withValues(alpha: 0.5)
                                          : colorScheme.primary
                                              .withValues(alpha: 0.5),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.person,
                                size: 64,
                                color: widget.user.isSuperuser == true
                                    ? colorScheme.primary.withValues(alpha: 0.5)
                                    : widget.user.isStaff == true
                                        ? colorScheme.tertiary
                                            .withValues(alpha: 0.5)
                                        : colorScheme.primary
                                            .withValues(alpha: 0.5),
                              ),
                            ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.black.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // User Status Indicators
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        if (widget.user.isSuperuser == true)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  color: colorScheme.onPrimary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Admin',
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.user.isStaff == true)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.tertiary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.badge,
                                  color: colorScheme.onTertiary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Staff',
                                  style: TextStyle(
                                    color: colorScheme.onTertiary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.user.isActive == true
                                ? Colors.green
                                : Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.user.isActive == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.user.isActive == true
                                    ? 'Active'
                                    : 'Inactive',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete Button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showDeleteConfirmationDialog(context),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // User Name and Email
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.user.firstName?.isNotEmpty == true ? widget.user.firstName : 'N/A'} ${widget.user.lastName?.isNotEmpty == true ? widget.user.lastName : 'N/A'}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.email?.isNotEmpty == true
                              ? widget.user.email!
                              : 'N/A',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // User Details
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: widget.user.isActive == true
                          ? Colors.green
                          : Colors.red.shade600,
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          _buildInfoRow(
                            'Title',
                            widget.user.title?.isNotEmpty == true
                                ? widget.user.title!
                                : 'N/A',
                            Icons.work_outline,
                            context: context,
                          ),
                          if (widget.user.title?.isNotEmpty == true)
                            const SizedBox(height: 16),
                          // Date Joined
                          _buildInfoRow(
                            'Date Joined',
                            widget.user.dateJoined != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(widget.user.dateJoined!)
                                : 'N/A',
                            Icons.calendar_today,
                            context: context,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Last Updated
                          _buildInfoRow(
                            'Last Updated',
                            widget.user.dateUpdated != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(widget.user.dateUpdated!)
                                : 'N/A',
                            Icons.update,
                            context: context,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
