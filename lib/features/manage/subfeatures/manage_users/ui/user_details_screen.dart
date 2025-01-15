import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/screens/user_active_sessions_screen.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/screens/user_logs_screen.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/screens/user_projects_screen.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/ui/screens/user_services_screen.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

class UserDetailsScreen extends StatefulWidget {
  final bool? isDic;
  final User user;

  const UserDetailsScreen({
    super.key,
    required this.user,
    this.isDic,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController confirmController = TextEditingController();
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController titleController;
  late final TextEditingController maxActiveSessionsController;
  bool isActive = false;
  bool isStaff = false;
  bool isSuperuser = false;
  XFile? selectedImage;
  late User _localUser;
  @override
  void initState() {
    super.initState();
    // Initialize local copy with the passed user data
    _localUser = widget.user;

    // Initialize controllers with current user data
    firstNameController = TextEditingController(text: _localUser.firstName);
    lastNameController = TextEditingController(text: _localUser.lastName);
    emailController = TextEditingController(text: _localUser.email);
    titleController = TextEditingController(text: _localUser.title);
    maxActiveSessionsController = TextEditingController(
        text: _localUser.maxActiveSessions?.toString() ?? '');
    isActive = _localUser.isActive == true;
    isStaff = _localUser.isStaff == true;
    isSuperuser = _localUser.isSuperuser == true;
  }

  @override
  void dispose() {
    confirmController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    titleController.dispose();
    maxActiveSessionsController.dispose();
    super.dispose();
  }

  Future<void> _showEditDialog(BuildContext context) async {
    bool isLoading = false;
    final cubit = context.read<ManageUsersCubit>();
    final ImagePicker picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          image: selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(File(selectedImage!.path)),
                                  fit: BoxFit.cover,
                                )
                              : _localUser.pictureUrl?.isNotEmpty == true
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(_localUser.pictureUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: selectedImage == null &&
                                _localUser.pictureUrl?.isNotEmpty != true
                            ? Icon(
                                Icons.person,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          onPressed: () async {
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setState(() => selectedImage = image);
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // First Name
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),

                // Last Name
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 16),

                // Max Active Sessions
                TextField(
                  controller: maxActiveSessionsController,
                  decoration: const InputDecoration(
                    labelText: 'Max Active Sessions',
                    prefixIcon: Icon(Icons.devices),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Active Switch
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                ),

                // Staff Switch
                SwitchListTile(
                  title: const Text('Staff'),
                  value: isStaff,
                  onChanged: (value) => setState(() => isStaff = value),
                ),

                // Superuser Switch
                SwitchListTile(
                  title: const Text('Superuser'),
                  value: isSuperuser,
                  onChanged: (value) => setState(() => isSuperuser = value),
                ),

                // Loading Indicator
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),

            // Save Button
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);

                      // Call the cubit to update the user
                      await cubit.updateUser(
                        _localUser.userId.toString(),
                        firstNameController.text,
                        lastNameController.text,
                        emailController.text,
                        null, // phone number not implemented
                        titleController.text,
                        int.tryParse(maxActiveSessionsController.text),
                        isActive,
                        isStaff,
                        isSuperuser,
                        selectedImage,
                      );
                      cubit.getAllUsers();
                      if (context.mounted) {
                        // Update local copy of user details
                        setState(() {
                          _localUser = _localUser.copyWith(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            title: titleController.text,
                            maxActiveSessions:
                                int.tryParse(maxActiveSessionsController.text),
                            isActive: isActive,
                            isStaff: isStaff,
                            isSuperuser: isSuperuser,
                          );
                        });

                        Navigator.of(context).pop();
                      }
                    },
              child: const Text('Save'),
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
        if (state is ManageUsersUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated successfully')),
          );
        } else if (state is ManageUsersUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              '${_localUser.firstName?.isNotEmpty == true ? _localUser.firstName : 'N/A'} ${_localUser.lastName?.isNotEmpty == true ? _localUser.lastName : 'N/A'}'),
          actions: [
            IconButton(
              onPressed: () => _showEditDialog(context),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => _showDeleteConfirmationDialog(context),
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
            ),
          ],
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.menu_rounded,
          activeIcon: Icons.close,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          activeBackgroundColor: colorScheme.error,
          activeForegroundColor: colorScheme.onError,
          elevation: 8.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          children: [
            if (widget.isDic != true)
              SpeedDialChild(
                child: const Icon(Icons.folder),
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                label: 'Projects',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => sl<ManageUsersCubit>()
                        ..getUserProjects(_localUser.userId!),
                      child: UserProjectsScreen(user: _localUser),
                    ),
                  ),
                ),
              ),
            if (widget.isDic != true)
              SpeedDialChild(
                child: const Icon(Icons.history),
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                label: 'Logs',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserLogsScreen(user: _localUser),
                  ),
                ),
              ),
            if (widget.isDic != true)
              SpeedDialChild(
                child: const Icon(Icons.devices),
                backgroundColor: colorScheme.tertiaryContainer,
                foregroundColor: colorScheme.onTertiaryContainer,
                label: 'Active Sessions',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        UserActiveSessionsScreen(user: _localUser),
                  ),
                ),
              ),
            SpeedDialChild(
              child: const Icon(Icons.miscellaneous_services),
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurfaceVariant,
              label: 'Services',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => sl<ManageUsersCubit>()
                      ..getDics(_localUser.userId!.toString()),
                    child: UserServicesScreen(user: _localUser),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
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
                    image: _localUser.pictureUrl?.isNotEmpty == true
                        ? DecorationImage(
                            image: NetworkImage(_localUser.pictureUrl!),
                            fit: BoxFit.cover,
                            onError: (error, stackTrace) {},
                          )
                        : null,
                  ),
                  child: _localUser.pictureUrl?.isNotEmpty != true
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
                value: _localUser.email?.isNotEmpty == true
                    ? _localUser.email!
                    : 'N/A',
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'First Name',
                value: _localUser.firstName?.isNotEmpty == true
                    ? _localUser.firstName!
                    : 'N/A',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Last Name',
                value: _localUser.lastName?.isNotEmpty == true
                    ? _localUser.lastName!
                    : 'N/A',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Title',
                value: _localUser.title?.isNotEmpty == true
                    ? _localUser.title!
                    : 'N/A',
                icon: Icons.work,
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                context,
                title: 'Active',
                value: _localUser.isActive == true,
                icon: Icons.check_circle,
                activeColor: Colors.green,
                inactiveColor: Colors.red.shade600,
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                context,
                title: 'Staff',
                value: _localUser.isStaff == true,
                icon: Icons.badge,
                activeColor: colorScheme.secondary,
                inactiveColor: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                context,
                title: 'Superuser',
                value: _localUser.isSuperuser == true,
                icon: Icons.admin_panel_settings,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Max Active Sessions',
                value: _localUser.maxActiveSessions?.toString() ?? 'N/A',
                icon: Icons.devices,
                isNumber: true,
              ),
            ],
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

  bool navigateToManageUsers = false;

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
