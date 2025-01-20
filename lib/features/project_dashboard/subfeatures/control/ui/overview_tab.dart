import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_update_request.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/editable_info_row.dart';
import 'package:pulsehub/features/projects/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

class OverviewTab extends StatefulWidget {
  final Project project;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const OverviewTab({
    super.key,
    required this.project,
    required this.isEditing,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}
class _OverviewTabState extends State<OverviewTab> {
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _deleteConfirmController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _deleteConfirmController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    _controllers.clear();
    _addController('title', widget.project.title);
    _addController('acronym', widget.project.acronym);
    _addController('startDate', widget.project.startDate);
    _addController('duration', widget.project.duration);
    _addController('budget', widget.project.budget);
    _addController('consultant', widget.project.consultant);
    _addController('contractor', widget.project.contractor);
    _addController('constructionDate', widget.project.constructionDate);
    _addController('constructionCharacteristics',
        widget.project.constructionCharacteristics);
    _addController('description', widget.project.description);
    _addController('timeZone', widget.project.timeZone);
    _addController('cordinateSystem', widget.project.coordinateSystem);
    _addController('dateFormate', widget.project.dateFormat);
    _addController('typeOfBuilding', widget.project.typeOfBuilding);
    _addController('size', widget.project.size);
    _addController('ageOfBuilding', widget.project.ageOfBuilding);
    _addController('structure', widget.project.structure);
    _addController('buildingHistory', widget.project.buildingHistory);
    _addController(
        'surroundingEnvironment', widget.project.surroundingEnvironment);
    _addController('importanceOfRiskIdentification',
        widget.project.importanceOfRiskIdentification);
    _addController('budgetConstraints', widget.project.budgetConstraints);
    _addController('plansAndFiles', widget.project.plansAndFiles);
  }

  void _addController(String field, String? value) {
    _controllers[field] = TextEditingController();
  }

  ProjectUpdateRequest _collectChanges() {
    Map<String, String?> changes = {};

    _controllers.forEach((field, controller) {
      // Only include fields that have non-empty text
      if (controller.text.trim().isNotEmpty) {
        changes[field] = controller.text.trim();
      }
    });

    // Only include non-null fields in the request
    return ProjectUpdateRequest(
      title: changes['title'],
      acronym: changes['acronym'],
      startDate: changes['startDate'],
      duration: changes['duration'],
      budget: changes['budget'],
      consultant: changes['consultant'],
      contractor: changes['contractor'],
      constructionDate: changes['constructionDate'],
      constructionCharacteristics: changes['constructionCharacteristics'],
      description: changes['description'],
      timeZone: changes['timeZone'],
      cordinateSystem: changes['cordinateSystem'],
      dateFormate: changes['dateFormate'],
      typeOfBuilding: changes['typeOfBuilding'],
      size: changes['size'],
      ageOfBuilding: changes['ageOfBuilding'],
      structure: changes['structure'],
      buildingHistory: changes['buildingHistory'],
      surroundingEnvironment: changes['surroundingEnvironment'],
      importanceOfRiskIdentification: changes['importanceOfRiskIdentification'],
      budgetConstraints: changes['budgetConstraints'],
      plansAndFiles: changes['plansAndFiles'],
    );
  }

  void _handleSave() async {
    final request = _collectChanges();
    await context
        .read<ProjectDashboardCubit>()
        .updateProject(widget.project.projectId!, request);
    widget.onSave();
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    _deleteConfirmController.clear();
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this project?'),
            const SizedBox(height: 16),
            Text(
              'To confirm deletion, please copy the project name: ${widget.project.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _deleteConfirmController,
              decoration: const InputDecoration(
                hintText: 'Enter project name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              if (_deleteConfirmController.text == widget.project.title) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Project name does not match'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete Project'),
          ),
        ],
      ),
    );
  }

  void _handleDelete() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      if (!mounted) return;
      await context
          .read<ProjectDashboardCubit>()
          .deleteProject(widget.project.projectId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
      listener: (context, state) {
        if (state is ProjectDashboardUpdateProjectSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<ProjectsCubit>().getProject(widget.project.projectId!);
          widget.onSave();
        } else if (state is ProjectDashboardUpdateProjectFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update project: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProjectDashboardDeleteProjectSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Return to projects list
        } else if (state is ProjectDashboardDeleteProjectFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete project: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
        builder: (context, dashState) {
          final isLoading = dashState is ProjectDashboardUpdateProjectLoading ||
              dashState is ProjectDashboardDeleteProjectLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: widget.isEditing ? 48 : 160,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: ClipRect(
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red.shade700,
                                      padding: widget.isEditing
                                          ? const EdgeInsets.all(8)
                                          : const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                    ),
                                    onPressed: isLoading ? null : _handleDelete,
                                    icon: const Icon(Icons.delete_forever,
                                        size: 20),
                                    label: widget.isEditing
                                        ? const SizedBox.shrink()
                                        : const Text('Delete'),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: !widget.isEditing
                                  ? FilledButton.icon(
                                      key: const ValueKey('edit'),
                                      onPressed:
                                          isLoading ? null : widget.onEdit,
                                      icon: const Icon(Icons.edit, size: 20),
                                      label: const Text('Edit'),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      key: const ValueKey('save-cancel'),
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: isLoading
                                              ? null
                                              : widget.onCancel,
                                          icon: const Icon(Icons.cancel,
                                              size: 20),
                                          label: const Text('Cancel'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        FilledButton.icon(
                                          onPressed:
                                              isLoading ? null : _handleSave,
                                          icon: isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : const Icon(Icons.save,
                                                  size: 20),
                                          label: Text(
                                              isLoading ? 'Saving' : 'Save'),
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    EditableInfoRow(
                      label: 'Project Title:',
                      value: widget.project.title ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['title'],
                    ),
                    EditableInfoRow(
                      label: 'Project Acronym:',
                      value: widget.project.acronym ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['acronym'],
                    ),
                    EditableInfoRow(
                      label: 'Start Date:',
                      value: widget.project.startDate ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['startDate'],
                    ),
                    EditableInfoRow(
                      label: 'Duration:',
                      value: widget.project.duration ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['duration'],
                    ),
                    EditableInfoRow(
                      label: 'Budget:',
                      value: widget.project.budget ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['budget'],
                    ),
                    EditableInfoRow(
                      label: 'Consultant:',
                      value: widget.project.consultant ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['consultant'],
                    ),
                    EditableInfoRow(
                      label: 'Contractor:',
                      value: widget.project.contractor ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['contractor'],
                    ),
                    EditableInfoRow(
                      label: 'Construction Date:',
                      value: widget.project.constructionDate ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['constructionDate'],
                    ),
                    EditableInfoRow(
                      label: 'Age of building:',
                      value: widget.project.ageOfBuilding ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['ageOfBuilding'],
                    ),
                    EditableInfoRow(
                      label: 'Type of building:',
                      value: widget.project.typeOfBuilding ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['typeOfBuilding'],
                    ),
                    EditableInfoRow(
                      label: 'Size of building:',
                      value: widget.project.size ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['size'],
                    ),
                    EditableInfoRow(
                      label: 'Structure:',
                      value: widget.project.structure ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['structure'],
                    ),
                    EditableInfoRow(
                      label: 'Building History:',
                      value: widget.project.buildingHistory ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['buildingHistory'],
                    ),
                    EditableInfoRow(
                      label: 'Surrounding Environment:',
                      value: widget.project.surroundingEnvironment ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['surroundingEnvironment'],
                    ),
                    EditableInfoRow(
                      label: 'Importance of Risk Identification:',
                      value: widget.project.importanceOfRiskIdentification ??
                          'N/A',
                      isEditing: widget.isEditing,
                      controller:
                          _controllers['importanceOfRiskIdentification'],
                    ),
                    EditableInfoRow(
                      label: 'Budget Constraints:',
                      value: widget.project.budgetConstraints ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['budgetConstraints'],
                    ),
                    EditableInfoRow(
                      label: 'Plans and files:',
                      value: widget.project.plansAndFiles ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['plansAndFiles'],
                    ),
                    EditableInfoRow(
                      label: 'Description:',
                      value: widget.project.description ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['description'],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Project Settings',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EditableInfoRow(
                      label: 'Time Zone:',
                      value: widget.project.timeZone ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['timeZone'],
                    ),
                    EditableInfoRow(
                      label: 'Coordinate System:',
                      value: widget.project.coordinateSystem ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['cordinateSystem'],
                    ),
                    EditableInfoRow(
                      label: 'Date Format:',
                      value: widget.project.dateFormat ?? 'N/A',
                      isEditing: widget.isEditing,
                      controller: _controllers['dateFormate'],
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
