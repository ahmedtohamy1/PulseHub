import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart'
    as monitoring;
import 'package:pulsehub/features/project_dashboard/data/models/project_update_request.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/used_sensors_table.dart';
import 'package:pulsehub/features/projects/cubit/projects_cubit.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == 1) {
      // Customisation tab
      context.read<ProjectDashboardCubit>().getUsedSensors();
    }
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
                  setState(() => _isEditing = false);
                },
              ),
              CustomisationTab(project: widget.project),
              MediaLibraryTab(projectId: widget.project.projectId!),
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

class CustomisationTab extends StatefulWidget {
  final Project project;
  const CustomisationTab({super.key, required this.project});

  @override
  State<CustomisationTab> createState() => _CustomisationTabState();
}

class _CustomisationTabState extends State<CustomisationTab> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final cubit = context.read<ProjectDashboardCubit>();
    await cubit.getUsedSensors();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      builder: (context, state) {
        if (state is ProjectDashboardGetUsedSensorsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectDashboardGetUsedSensorsFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ProjectDashboardGetUsedSensorsSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: UsedSensorsTable(
                  usedSensors:
                      state.getUsedSensorsResponseModel.usedSensorList ?? [],
                  projectId: widget.project.projectId!,
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('No data available'));
      },
    );
  }
}

class MediaLibraryTab extends StatefulWidget {
  final int projectId;

  const MediaLibraryTab({
    super.key,
    required this.projectId,
  });

  @override
  State<MediaLibraryTab> createState() => _MediaLibraryTabState();
}

class _MediaLibraryTabState extends State<MediaLibraryTab> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectDashboardCubit>().getMediaLibrary(widget.projectId);
  }

  Future<void> _downloadFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _showUploadDialog(BuildContext context) {
    PlatformFile? selectedFile;
    String fileName = '';
    String description = '';

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ProjectDashboardCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.upload_file, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Upload File'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedFile == null)
                  Center(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          setState(() {
                            selectedFile = result.files.first;
                            fileName = selectedFile!.name;
                          });
                        }
                      },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Choose File'),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedFile!.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () {
                                setState(() {
                                  selectedFile = null;
                                  fileName = '';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'File Name',
                          hintText: 'Enter file name without extension',
                          prefixIcon: const Icon(Icons.edit_document),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) =>
                            fileName = value + '.${selectedFile!.extension}',
                        controller: TextEditingController(
                          text: selectedFile!.name
                              .replaceAll('.${selectedFile!.extension}', ''),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Description (optional)',
                          hintText: 'Enter file description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                        onChanged: (value) => description = value,
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (selectedFile != null)
                FilledButton.icon(
                  onPressed: () async {
                    final token = await SharedPrefHelper.getSecuredString(
                        SharedPrefKeys.token);
                    context
                        .read<ProjectDashboardCubit>()
                        .createMediaLibraryFile(
                          token,
                          widget.projectId,
                          fileName,
                          description,
                          selectedFile!,
                        );
                    Navigator.pop(context);
                    context
                        .read<ProjectDashboardCubit>()
                        .getMediaLibrary(widget.projectId);
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectDashboardCubit, ProjectDashboardState>(
      listener: (context, state) {
        if (state is ProjectDashboardCreateMediaLibraryFileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProjectDashboardCreateMediaLibraryFileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload file: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProjectDashboardDeleteMediaLibrarySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context
              .read<ProjectDashboardCubit>()
              .getMediaLibrary(widget.projectId);
        } else if (state is ProjectDashboardDeleteMediaLibraryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete file: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProjectDashboardGetMediaLibraryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectDashboardGetMediaLibrarySuccess) {
          final files =
              state.getMediaLibrariesResponseModel.mediaLibraries ?? [];
          final isUploading =
              state is ProjectDashboardCreateMediaLibraryFileLoading;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder_open,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Media Library',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${files.length} file${files.length != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isUploading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => _showUploadDialog(context),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload File'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: files.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No files uploaded yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              onPressed: () => _showUploadDialog(context),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload your first file'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          final file = files[index];
                          final isImage = file.fileName
                                      ?.toLowerCase()
                                      .endsWith('.jpg') ==
                                  true ||
                              file.fileName?.toLowerCase().endsWith('.jpeg') ==
                                  true ||
                              file.fileName?.toLowerCase().endsWith('.png') ==
                                  true ||
                              file.fileName?.toLowerCase().endsWith('.gif') ==
                                  true;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              elevation: 2,
                              child: InkWell(
                                onTap: () {
                                  if (file.fileUrl != null) {
                                    _downloadFile(file.fileUrl!);
                                  }
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withOpacity(0.1),
                                      child: isImage && file.fileUrl != null
                                          ? Image.network(
                                              file.fileUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Center(
                                                      child: Icon(Icons.error)),
                                            )
                                          : Center(
                                              child: Icon(
                                                _getFileIcon(
                                                    file.fileName ?? ''),
                                                size: 48,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              file.fileName ?? 'Unnamed file',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(file.createdAt),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            if (file.description != null) ...[
                                              const SizedBox(height: 12),
                                              Text(
                                                file.description.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                FilledButton.tonalIcon(
                                                  onPressed: () {
                                                    if (file.fileUrl != null) {
                                                      _downloadFile(
                                                          file.fileUrl!);
                                                    }
                                                  },
                                                  icon: const Icon(
                                                      Icons.download,
                                                      size: 18),
                                                  label: const Text('Download'),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .errorContainer,
                                                    foregroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .error,
                                                    minimumSize:
                                                        const Size(40, 40),
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Delete File'),
                                                        content: Text(
                                                            'Are you sure you want to delete "${file.fileName}"?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'Cancel'),
                                                          ),
                                                          FilledButton(
                                                            style: FilledButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .error,
                                                            ),
                                                            onPressed: () {
                                                              if (file.mediaLibraryId !=
                                                                  null) {
                                                                context
                                                                    .read<
                                                                        ProjectDashboardCubit>()
                                                                    .deleteMediaLibrary(
                                                                        file.mediaLibraryId!);
                                                                Navigator.pop(
                                                                    context);
                                                              }
                                                            },
                                                            child: const Text(
                                                                'Delete'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                      Icons.delete_outline,
                                                      size: 18),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }

        return Center(
          child: FilledButton.icon(
            onPressed: () {
              context
                  .read<ProjectDashboardCubit>()
                  .getMediaLibrary(widget.projectId);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Load Media Library'),
          ),
        );
      },
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.article;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
