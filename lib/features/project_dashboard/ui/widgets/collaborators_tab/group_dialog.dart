import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';

class GroupDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialDescription;
  final bool initialIsViewer;
  final bool initialIsAnalyzer;
  final bool initialIsEditor;
  final bool initialIsMonitor;
  final bool initialIsManager;
  final bool initialIsNotificationsSender;
  final Function(
    String name,
    String description,
    bool isViewer,
    bool isAnalyzer,
    bool isEditor,
    bool isMonitor,
    bool isManager,
    bool isNotificationsSender,
  ) onSave;

  const GroupDialog({
    super.key,
    required this.title,
    this.initialName,
    this.initialDescription,
    this.initialIsViewer = false,
    this.initialIsAnalyzer = false,
    this.initialIsEditor = false,
    this.initialIsMonitor = false,
    this.initialIsManager = false,
    this.initialIsNotificationsSender = false,
    required this.onSave,
  });

  @override
  State<GroupDialog> createState() => _GroupDialogState();
}

class _GroupDialogState extends State<GroupDialog> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late bool isViewer;
  late bool isAnalyzer;
  late bool isEditor;
  late bool isMonitor;
  late bool isManager;
  late bool isNotificationsSender;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
    isViewer = widget.initialIsViewer;
    isAnalyzer = widget.initialIsAnalyzer;
    isEditor = widget.initialIsEditor;
    isMonitor = widget.initialIsMonitor;
    isManager = widget.initialIsManager;
    isNotificationsSender = widget.initialIsNotificationsSender;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
      listenWhen: (previous, current) =>
          current is ProjectDashboardUpdateCollaboratorsSuccess ||
          current is ProjectDashboardUpdateCollaboratorsFailure ||
          current is ProjectDashboardCreateCollaboratorsGroupSuccess ||
          current is ProjectDashboardCreateCollaboratorsGroupFailure,
      listener: (context, state) {
        if (state is ProjectDashboardUpdateCollaboratorsSuccess ||
            state is ProjectDashboardCreateCollaboratorsGroupSuccess) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        } else if (state is ProjectDashboardUpdateCollaboratorsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update group: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProjectDashboardCreateCollaboratorsGroupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create group: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
        buildWhen: (previous, current) =>
            current is ProjectDashboardUpdateCollaboratorsLoading ||
            current is ProjectDashboardUpdateCollaboratorsFailure ||
            current is ProjectDashboardCreateCollaboratorsGroupLoading ||
            current is ProjectDashboardCreateCollaboratorsGroupFailure,
        builder: (context, state) {
          final isLoading =
              state is ProjectDashboardUpdateCollaboratorsLoading ||
                  state is ProjectDashboardCreateCollaboratorsGroupLoading;

          return AlertDialog(
            title: Text(widget.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                    enabled: !isLoading,
                    onChanged: (value) =>
                        setState(() => isViewer = value ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Analyzer'),
                    value: isAnalyzer,
                    enabled: !isLoading,
                    onChanged: (value) =>
                        setState(() => isAnalyzer = value ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Editor'),
                    value: isEditor,
                    enabled: !isLoading,
                    onChanged: (value) =>
                        setState(() => isEditor = value ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Monitor'),
                    value: isMonitor,
                    enabled: !isLoading,
                    onChanged: (value) =>
                        setState(() => isMonitor = value ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Manager'),
                    value: isManager,
                    enabled: !isLoading,
                    onChanged: (value) =>
                        setState(() => isManager = value ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Notifications Sender'),
                    value: isNotificationsSender,
                    enabled: !isLoading,
                    onChanged: (value) =>
                        setState(() => isNotificationsSender = value ?? false),
                  ),
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

                    widget.onSave(
                      name,
                      descriptionController.text.trim(),
                      isViewer,
                      isAnalyzer,
                      isEditor,
                      isMonitor,
                      isManager,
                      isNotificationsSender,
                    );
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
