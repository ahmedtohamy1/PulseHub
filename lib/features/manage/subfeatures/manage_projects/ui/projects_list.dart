import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/cubit/manage_projects_cubit.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/get_all_projects_response_model.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart'
    as owner_model;
import 'package:pulsehub/features/manage/subfeatures/manage_projects/ui/add_project_screen.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/ui/project_card.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/number_input.dart';

class ProjectsList extends StatefulWidget {
  final List<Project> projects;

  const ProjectsList({super.key, required this.projects});

  @override
  State<ProjectsList> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';
  File? _selectedImage;
  final _imagePicker = ImagePicker();
  owner_model.OwnerModel? _selectedOwner;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Project> get _filteredProjects {
    if (_searchQuery.isEmpty) return widget.projects;
    final query = _searchQuery.toLowerCase();
    return widget.projects
        .where((project) =>
            project.title.toLowerCase().contains(query) ||
            project.acronym!.toLowerCase().contains(query))
        .toList();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Main List
        GestureDetector(
          onTap: _showSearch ? _toggleSearch : null,
          behavior: HitTestBehavior.translucent,
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80, // Extra padding for FAB
            ),
            itemCount: _filteredProjects.length,
            itemBuilder: (context, index) {
              final project = _filteredProjects[index];
              return ProjectCard(project: project);
            },
          ),
        ),

        // Search TextField
        if (_showSearch)
          Positioned(
            right: 16,
            bottom: 80,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.primary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

        // FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showSearch)
                FloatingActionButton(
                  heroTag: 'searchFab',
                  onPressed: _toggleSearch,
                  child: Icon(
                    Icons.close,
                    color: colorScheme.onPrimaryContainer,
                  ),
                )
              else ...[
                FloatingActionButton(
                  heroTag: 'addFab',
                  onPressed: () async {
                    // Store cubit instance
                    final cubit = context.read<ManageProjectsCubit>();

                    // Navigate and wait for result
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: cubit,
                          child: const AddProjectScreen(),
                        ),
                      ),
                    );

                    // Refresh projects list if we returned from add screen
                    if (result == true && mounted) {
                      cubit.getAllProjects();
                    }
                  },
                  child: Icon(
                    Icons.add,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'searchFab',
                  onPressed: _toggleSearch,
                  child: Icon(
                    Icons.search,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showAddProjectSheet(BuildContext context) {
    // Reset image when opening sheet
    _selectedImage = null;
    _selectedOwner = null;

    // Store cubit instance
    final cubit = context.read<ManageProjectsCubit>();

    final titleController = TextEditingController();
    final acronymController = TextEditingController();
    final startDateController = TextEditingController();
    final durationController = TextEditingController();
    final consultantController = TextEditingController();
    final contractorController = TextEditingController();
    final constructionDateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: cubit,
          ),
        ],
        child: StatefulBuilder(
          builder: (context, setModalState) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add New Project',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton.filled(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Picker
                        Text(
                          'Project Picture',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            try {
                              final XFile? image = await _imagePicker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (image != null && mounted) {
                                setModalState(() {
                                  _selectedImage = File(image.path);
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error selecting image: ${e.toString()}'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _selectedImage != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface
                                                  .withValues(alpha: 0.9),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              onPressed: () async {
                                                try {
                                                  final XFile? image =
                                                      await _imagePicker
                                                          .pickImage(
                                                    source: ImageSource.gallery,
                                                    imageQuality: 80,
                                                  );
                                                  if (image != null &&
                                                      mounted) {
                                                    setModalState(() {
                                                      _selectedImage =
                                                          File(image.path);
                                                    });
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Error updating image: ${e.toString()}'),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 48,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add Project Picture',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tap to select',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title and Acronym
                        _buildTextField(
                          label: 'Title',
                          controller: titleController,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Acronym',
                          controller: acronymController,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 16),

                        // Owner Dropdown
                        Text(
                          'Owner',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<ManageProjectsCubit, ManageProjectsState>(
                          builder: (context, state) {
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: switch (state) {
                                GetAllOwnersSuccess(owners: final owners) =>
                                  (() {
                                    return DropdownButtonFormField<String>(
                                      value: _selectedOwner?.name,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        isDense: true,
                                      ),
                                      items: owners.map((owner) {
                                        return DropdownMenuItem<String>(
                                          value: owner.name,
                                          child: Text(owner.name),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        if (value != null && mounted) {
                                          try {
                                            final selectedOwner =
                                                owners.firstWhere(
                                              (owner) => owner.name == value,
                                              orElse: () => owners.first,
                                            );
                                            if (mounted) {
                                              setModalState(() {
                                                _selectedOwner = selectedOwner;
                                              });
                                            }
                                          } catch (e) {
                                            rethrow;
                                          }
                                        }
                                      },
                                      hint: const Text('Select Owner'),
                                      isExpanded: true,
                                    );
                                  })(),
                                GetAllOwnersLoading() =>
                                  DropdownButtonFormField<String>(
                                    value: null,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      isDense: true,
                                      suffixIcon: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    items: const [],
                                    onChanged: null,
                                    hint: const Text('Loading owners...'),
                                    isExpanded: true,
                                  ),
                                GetAllOwnersFailure(error: final error) =>
                                  DropdownButtonFormField<String>(
                                    value: null,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                      isDense: true,
                                      helperText: 'Error: $error',
                                      helperStyle: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          Icons.refresh,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<ManageProjectsCubit>()
                                              .getAllOwners();
                                        },
                                      ),
                                    ),
                                    items: const [],
                                    onChanged: null,
                                    hint: Text(
                                      'Failed to load owners',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                    isExpanded: true,
                                  ),
                                _ => const SizedBox(),
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Date Fields
                        _buildDateField(
                          context: context,
                          label: 'Start Date',
                          controller: startDateController,
                        ),
                        const SizedBox(height: 8),
                        _buildDateField(
                          context: context,
                          label: 'Construction Date',
                          controller: constructionDateController,
                        ),
                        const SizedBox(height: 8),
                        // Number Input Fields
                        NumberInput(
                          label: 'Duration (months)',
                          controller: durationController,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 8),

                        // Regular Text Fields
                        _buildTextField(
                          label: 'Consultant',
                          controller: consultantController,
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          label: 'Contractor',
                          controller: contractorController,
                        ),

                        const SizedBox(height: 32),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              if (_selectedOwner != null) {
                                // TODO: Implement project creation
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select an owner'),
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Create Project'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      // Dispose controllers
      titleController.dispose();
      acronymController.dispose();
      startDateController.dispose();
      durationController.dispose();
      consultantController.dispose();
      contractorController.dispose();
      constructionDateController.dispose();
    });
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                controller.text = DateFormat('yyyy-MM-dd').format(date);
              }
            },
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
