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
    _controllers[field] = TextEditingController(text: value);
  }

  ProjectUpdateRequest _collectChanges() {
    Map<String, String?> changes = {};

    _controllers.forEach((field, controller) {
      if (controller.text.trim().isNotEmpty) {
        changes[field] = controller.text.trim();
      }
    });

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

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              border: Border(
                left: BorderSide(
                  color: colorScheme.primary,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
      listener: (context, state) {
        if (state is ProjectDashboardUpdateProjectSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Project updated successfully'),
                backgroundColor: Colors.green),
          );
          context.read<ProjectsCubit>().getProject(widget.project.projectId!);
          widget.onSave();
        } else if (state is ProjectDashboardUpdateProjectFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update project: ${state.message}'),
                backgroundColor: Colors.red),
          );
        } else if (state is ProjectDashboardDeleteProjectSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Project deleted successfully'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        } else if (state is ProjectDashboardDeleteProjectFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete project: ${state.message}'),
                backgroundColor: Colors.red),
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
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Actions Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: isLoading ? null : _handleDelete,
                          icon: const Icon(Icons.delete_forever, size: 20),
                          label: const Text('Delete'),
                        ),
                        const SizedBox(width: 8),
                        if (!widget.isEditing)
                          FilledButton.icon(
                            onPressed: isLoading ? null : widget.onEdit,
                            icon: const Icon(Icons.edit, size: 20),
                            label: const Text('Edit'),
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                onPressed: isLoading ? null : widget.onCancel,
                                icon: const Icon(Icons.cancel, size: 20),
                                label: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: isLoading ? null : _handleSave,
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save, size: 20),
                                label: Text(isLoading ? 'Saving' : 'Save'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Basic Information Card
                    _buildInfoCard(
                      context,
                      title: 'Basic Information',
                      icon: Icons.apartment_rounded,
                      children: [
                        EditableInfoRow(
                          label: 'Project Title',
                          value: widget.project.title ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['title'],
                          icon: Icons.title_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Project Acronym',
                          value: widget.project.acronym ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['acronym'],
                          icon: Icons.short_text_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Description',
                          value: widget.project.description ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['description'],
                          icon: Icons.description_rounded,
                        ),
                      ],
                    ),

                    // Timeline Card
                    _buildInfoCard(
                      context,
                      title: 'Timeline',
                      icon: Icons.event_note_rounded,
                      children: [
                        EditableInfoRow(
                          label: 'Start Date',
                          value: widget.project.startDate ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['startDate'],
                          icon: Icons.calendar_today_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Duration',
                          value: widget.project.duration ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['duration'],
                          icon: Icons.timer_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Construction Date',
                          value: widget.project.constructionDate ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['constructionDate'],
                          icon: Icons.construction_rounded,
                        ),
                      ],
                    ),

                    // Financial Information Card
                    _buildInfoCard(
                      context,
                      title: 'Financial Information',
                      icon: Icons.account_balance_rounded,
                      children: [
                        EditableInfoRow(
                          label: 'Budget',
                          value: widget.project.budget ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['budget'],
                          icon: Icons.monetization_on_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Budget Constraints',
                          value: widget.project.budgetConstraints ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['budgetConstraints'],
                          icon: Icons.money_off_rounded,
                        ),
                      ],
                    ),

                    // Building Details Card
                    _buildInfoCard(
                      context,
                      title: 'Building Details',
                      icon: Icons.domain_rounded,
                      children: [
                        EditableInfoRow(
                          label: 'Type of Building',
                          value: widget.project.typeOfBuilding ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['typeOfBuilding'],
                          icon: Icons.category_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Size',
                          value: widget.project.size ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['size'],
                          icon: Icons.square_foot_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Age of Building',
                          value: widget.project.ageOfBuilding ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['ageOfBuilding'],
                          icon: Icons.update_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Structure',
                          value: widget.project.structure ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['structure'],
                          icon: Icons.architecture_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Building History',
                          value: widget.project.buildingHistory ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['buildingHistory'],
                          icon: Icons.history_rounded,
                        ),
                      ],
                    ),

                    // Environment & Risk Card
                    _buildInfoCard(
                      context,
                      title: 'Environment & Risk',
                      icon: Icons.eco_rounded,
                      children: [
                        EditableInfoRow(
                          label: 'Surrounding Environment',
                          value: widget.project.surroundingEnvironment ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['surroundingEnvironment'],
                          icon: Icons.landscape_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Importance of Risk Identification',
                          value:
                              widget.project.importanceOfRiskIdentification ??
                                  'N/A',
                          isEditing: widget.isEditing,
                          controller:
                              _controllers['importanceOfRiskIdentification'],
                          icon: Icons.warning_rounded,
                        ),
                      ],
                    ),

                    // Project Settings Card
                    _buildInfoCard(
                      context,
                      title: 'Project Settings',
                      icon: Icons.tune_rounded,
                      children: [
                        EditableInfoRow(
                          label: 'Time Zone',
                          value: widget.project.timeZone ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['timeZone'],
                          icon: Icons.schedule_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Coordinate System',
                          value: widget.project.coordinateSystem ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['cordinateSystem'],
                          icon: Icons.gps_fixed_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Date Format',
                          value: widget.project.dateFormat ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['dateFormate'],
                          icon: Icons.date_range_rounded,
                        ),
                      ],
                    ),

                    // Team Card
                    _buildInfoCard(
                      context,
                      title: 'Team',
                      icon: Icons.groups_2_rounded,
                      children: [
                        EditableInfoRow(
                          label: 'Consultant',
                          value: widget.project.consultant ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['consultant'],
                          icon: Icons.person_rounded,
                        ),
                        EditableInfoRow(
                          label: 'Contractor',
                          value: widget.project.contractor ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['contractor'],
                          icon: Icons.engineering_rounded,
                        ),
                      ],
                    ),

                    // Documents Card
                    _buildInfoCard(
                      context,
                      title: 'Documents',
                      icon: Icons.description_rounded,
                      children: [
                        EditableInfoRow(
                          label: 'Plans and Files',
                          value: widget.project.plansAndFiles ?? 'N/A',
                          isEditing: widget.isEditing,
                          controller: _controllers['plansAndFiles'],
                          icon: Icons.folder_rounded,
                        ),
                      ],
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
