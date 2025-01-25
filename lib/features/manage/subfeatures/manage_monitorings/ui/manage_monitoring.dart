import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_monitorings/cubit/manage_monitorings_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';

class ManageMonitoringsTab extends StatefulWidget {
  const ManageMonitoringsTab({super.key});

  @override
  State<ManageMonitoringsTab> createState() => _ManageMonitoringsTabState();
}

class _ManageMonitoringsTabState extends State<ManageMonitoringsTab> {
  late final ManageMonitoringsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ManageMonitoringsCubit>();

    _cubit.getMonitorings();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: const ManageMonitoringsView(),
    );
  }
}

class ManageMonitoringsView extends StatefulWidget {
  const ManageMonitoringsView({super.key});

  @override
  State<ManageMonitoringsView> createState() => _ManageMonitoringsViewState();
}

class _ManageMonitoringsViewState extends State<ManageMonitoringsView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Main List
          GestureDetector(
            onTap: _showSearch ? _toggleSearch : null,
            behavior: HitTestBehavior.translucent,
            child: BlocBuilder<ManageMonitoringsCubit, ManageMonitoringsState>(
              builder: (context, state) {
                // Show loading only if we have no monitoring data at all
                if (state is ManageMonitoringsLoading &&
                    state.monitoringResponse == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ManageMonitoringsFailure &&
                    state.monitoringResponse == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load monitorings',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.error,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            context
                                .read<ManageMonitoringsCubit>()
                                .getMonitorings();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Show monitorings from any state that has monitoringResponse
                final monitorings = state.monitoringResponse?.monitorings ?? [];

                if (monitorings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No monitorings found',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No monitorings have been added yet',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final filteredMonitorings = _searchQuery.isEmpty
                    ? monitorings
                    : monitorings
                        .where((monitoring) => monitoring.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 80, // Extra padding for FAB
                  ),
                  itemCount: filteredMonitorings.length,
                  itemBuilder: (context, index) {
                    final monitoring = filteredMonitorings[index];
                    return MonitoringCard(monitoring: monitoring);
                  },
                );
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
                      color: colorScheme.shadow.withOpacity(0.1),
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
                    hintText: 'Search monitorings...',
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
                        color: colorScheme.outline.withOpacity(0.5),
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
                    heroTag: 'manage_monitorings_search_close_fab',
                    onPressed: _toggleSearch,
                    child: Icon(
                      Icons.close,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  )
                else ...[
                  FloatingActionButton(
                    heroTag: 'manage_monitorings_add_fab',
                    onPressed: () {
                 
                    },
                    child: Icon(
                      Icons.add,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'manage_monitorings_search_fab',
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
      ),
    );
  }
}

class MonitoringCard extends StatelessWidget {
  final Monitoring monitoring;

  const MonitoringCard({
    super.key,
    required this.monitoring,
  });

  Future<void> _showEditMonitoringDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextEditingController nameController =
        TextEditingController(text: monitoring.name);
    final TextEditingController communicationsController =
        TextEditingController(text: monitoring.communications);
    int? selectedProjectId = monitoring.project;
    bool isLoading = false;
    final cubit = context.read<ManageMonitoringsCubit>();

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (context, setState) {
            // Load projects when dialog is first shown
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                cubit.getProjects();
              }
            });

            return PopScope(
              canPop: !isLoading, // Prevent popping while loading
              child: AlertDialog(
                title: Text(
                  'Edit Monitoring',
                  style: theme.textTheme.titleLarge,
                ),
                content: BlocConsumer<ManageMonitoringsCubit,
                    ManageMonitoringsState>(
                  listener: (context, state) {
                    if (state is ManageMonitoringsEditSuccess) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Monitoring updated successfully'),
                        ),
                      );
                      cubit.getMonitorings();
                    } else if (state is ManageMonitoringsEditFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error),
                          backgroundColor: colorScheme.error,
                        ),
                      );
                      setState(() => isLoading = false);
                    }
                  },
                  builder: (context, state) {
                    if (state is ManageMonitoringsGetProjectsLoading) {
                      return const Center(
                        heightFactor: 1,
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is ManageMonitoringsGetProjectsFailure) {
                      return Center(
                        child: Text(
                          'Failed to load projects: ${state.error}',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      );
                    }

                    if (state is ManageMonitoringsGetProjectsSuccess) {
                      final projects = state.projectsResponse?.projects ?? [];

                      // Check if selected project exists in available projects
                      final projectExists =
                          projects.any((p) => p.projectId == selectedProjectId);
                      if (!projectExists) {
                        selectedProjectId = null; // Reset if project not found
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.monitor),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: communicationsController,
                            decoration: const InputDecoration(
                              labelText: 'Communications',
                              prefixIcon: Icon(Icons.comment),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: selectedProjectId,
                            decoration: const InputDecoration(
                              labelText: 'Project',
                              prefixIcon: Icon(Icons.folder),
                            ),
                            items: projects.map((project) {
                              return DropdownMenuItem(
                                value: project.projectId,
                                child: Text(project.title),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedProjectId = value;
                              });
                            },
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isLoading
                            ? colorScheme.onSurface.withOpacity(0.38)
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: isLoading ||
                            nameController.text.isEmpty ||
                            selectedProjectId == null
                        ? null
                        : () async {
                            setState(() => isLoading = true);
                            await cubit.editMonitoring(
                              communicationsController.text.isEmpty
                                  ? null
                                  : communicationsController.text,
                              nameController.text,
                              selectedProjectId,
                              monitoring.monitoringId,
                            );
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextEditingController confirmController = TextEditingController();
    bool isLoading = false;
    final cubit = context.read<ManageMonitoringsCubit>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (context, setState) => PopScope(
            canPop: !isLoading,
            child: AlertDialog(
              title: Text(
                'Delete Monitoring',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              content:
                  BlocConsumer<ManageMonitoringsCubit, ManageMonitoringsState>(
                listener: (context, state) {
                  if (state is ManageMonitoringsDeleteSuccess) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Monitoring deleted successfully'),
                      ),
                    );
                    cubit.getMonitorings();
                  } else if (state is ManageMonitoringsDeleteFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                    setState(() => isLoading = false);
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This action cannot be undone. Please type "${monitoring.name}" to confirm.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmController,
                        decoration: InputDecoration(
                          hintText: 'Type monitoring name to confirm',
                          errorText: confirmController.text.isNotEmpty &&
                                  confirmController.text != monitoring.name
                              ? 'Name does not match'
                              : null,
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isLoading
                          ? colorScheme.onSurface.withOpacity(0.38)
                          : colorScheme.primary,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: isLoading ||
                          confirmController.text != monitoring.name
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          await cubit.deleteMonitoring(monitoring.monitoringId);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onError,
                          ),
                        )
                      : const Text('Delete'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.monitor,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monitoring.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'ID: ${monitoring.monitoringId}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colorScheme.outline,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Project ID: ${monitoring.project}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text('Edit Monitoring'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete Monitoring',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditMonitoringDialog(context);
                        break;
                      case 'delete':
                        _showDeleteConfirmationDialog(context);
                        break;
                    }
                  },
                ),
              ],
            ),
            if (monitoring.usedSensors?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              Text(
                'Used Sensors',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: monitoring.usedSensors!.map((sensor) {
                  return Chip(
                    label: Text(sensor.name),
                    avatar: const Icon(Icons.sensors),
                  );
                }).toList(),
              ),
            ],
            if (monitoring.communications?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              Text(
                'Communications',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                monitoring.communications!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
