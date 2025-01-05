import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_update_request.dart';
import 'package:pulsehub/features/projects/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

class ControlScreen extends StatefulWidget {
  final Project project;
  const ControlScreen({super.key, required this.project});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              width: 5,
              height: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0)),
              ),
            ),
            Text(
              'Project Control Panel',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TabBar(
          labelPadding: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 1),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Customisation'),
            Tab(text: 'Media Library'),
            Tab(text: 'Collaborators'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              OverviewTab(
                project: widget.project,
                isEditing: _isEditing,
                onEdit: () => setState(() => _isEditing = true),
                onCancel: () => setState(() => _isEditing = false),
                onSave: () {
                  // TODO: Implement save functionality
                  setState(() => _isEditing = false);
                },
              ),
              const Center(child: Text('Customisation content coming soon')),
              const Center(child: Text('Media Library content coming soon')),
              const Center(child: Text('Collaborators content coming soon')),
            ],
          ),
        ),
      ],
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
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
          // Refetch project data after successful update
          context.read<ProjectsCubit>().getProject(widget.project.projectId!);
          widget.onSave();
        } else if (state is ProjectDashboardUpdateProjectFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update project: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
        builder: (context, dashState) {
          final isLoading = dashState is ProjectDashboardUpdateProjectLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!widget.isEditing)
                          FilledButton.icon(
                            onPressed: isLoading ? null : widget.onEdit,
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          )
                        else ...[
                          OutlinedButton.icon(
                            onPressed: isLoading ? null : widget.onCancel,
                            icon: const Icon(Icons.cancel),
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
                                : const Icon(Icons.save),
                            label:
                                Text(isLoading ? 'Saving...' : 'Save Changes'),
                          ),
                        ],
                      ],
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

class EditableInfoRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isEditing;
  final TextEditingController? controller;

  const EditableInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.isEditing,
    this.controller,
  });

  @override
  State<EditableInfoRow> createState() => _EditableInfoRowState();
}

class _EditableInfoRowState extends State<EditableInfoRow> {
  bool get isDateField {
    return widget.label.toLowerCase().contains('date') ||
        widget.label.toLowerCase().contains('start');
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(widget.value) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && widget.controller != null) {
      // Display in MM/DD/YYYY format for UI
      final displayDate = "${picked.month}/${picked.day}/${picked.year}";
      // Store in YYYY-MM-DD format for API
      final apiDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      widget.controller!.text = apiDate;
      setState(() {
        _displayValue = displayDate;
      });
    }
  }

  DateTime? _parseDate(String value) {
    try {
      if (value == 'N/A') return null;

      // Try to parse YYYY-MM-DD format first
      if (value.contains('-')) {
        return DateTime.parse(value);
      }

      // Try to parse MM/DD/YYYY format
      final parts = value.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[0]), // month
          int.parse(parts[1]), // day
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  String? _displayValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: widget.isEditing
                ? isDateField
                    ? TextFormField(
                        controller: widget.controller,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          border: const OutlineInputBorder(),
                          hintText: widget.value,
                          hintStyle: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _showDatePicker(context),
                          ),
                        ),
                        // Show MM/DD/YYYY in the field but keep YYYY-MM-DD in the controller
                        onTap: () => _showDatePicker(context),
                      )
                    : TextFormField(
                        controller: widget.controller,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          border: const OutlineInputBorder(),
                          hintText: widget.value,
                          hintStyle: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      )
                : Text(_displayValue ?? widget.value),
          ),
        ],
      ),
    );
  }
}
