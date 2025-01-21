import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';

import '../cubit/manage_sensors_cubit.dart';
import '../data/models/get_all_sensor_types_response_model.dart';

class ManageSensorsTab extends StatefulWidget {
  const ManageSensorsTab({super.key});

  @override
  State<ManageSensorsTab> createState() => _ManageSensorsTabState();
}

class _ManageSensorsTabState extends State<ManageSensorsTab> {
  late final ManageSensorsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ManageSensorsCubit>();
    _cubit.getAllSensorTypes();
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
      child: const ManageSensorsView(),
    );
  }
}

class ManageSensorsView extends StatefulWidget {
  const ManageSensorsView({super.key});

  @override
  State<ManageSensorsView> createState() => _ManageSensorsViewState();
}

class _ManageSensorsViewState extends State<ManageSensorsView> {
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

  Future<void> _showCreateSensorDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController functionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ManageSensorsCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            return AlertDialog(
              title: Text(
                'Create Sensor Type',
                style: theme.textTheme.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.sensors),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update the state when text changes
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: functionController,
                    decoration: const InputDecoration(
                      labelText: 'Function',
                      prefixIcon: Icon(Icons.functions),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update the state when text changes
                    },
                  ),
                ],
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
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
                          : colorScheme.primary,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: isLoading ||
                          nameController.text.isEmpty ||
                          functionController.text.isEmpty
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          final cubit = context.read<ManageSensorsCubit>();
                          await cubit.createEditSensorType(
                            nameController.text,
                            functionController.text,
                            null, // null for create
                          );

                          if (!context.mounted) return;
                          Navigator.of(context).pop();

                          // Show result in snackbar
                          final state = cubit.state;
                          if (state is CreateEditSensorTypeSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Sensor type created successfully'),
                              ),
                            );
                            // Refresh the list
                            cubit.getAllSensorTypes();
                          } else if (state is CreateEditSensorTypeError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.error),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                            setState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        ),
      ),
    );
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
            child: BlocBuilder<ManageSensorsCubit, ManageSensorsState>(
              builder: (context, state) {
                if (state is ManageSensorsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ManageSensorsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load sensor types',
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
                                .read<ManageSensorsCubit>()
                                .getAllSensorTypes();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ManageSensorsLoaded) {
                  if (state.sensorTypes.sensorTypeList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No sensor types found',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No sensor types have been added yet',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredSensors = _searchQuery.isEmpty
                      ? state.sensorTypes.sensorTypeList
                      : state.sensorTypes.sensorTypeList
                          .where((sensor) =>
                              sensor.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              sensor.function
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
                    itemCount: filteredSensors.length,
                    itemBuilder: (context, index) {
                      final sensorType = filteredSensors[index];
                      return SensorCard(sensorType: sensorType);
                    },
                  );
                }

                return const SizedBox.shrink();
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
                    hintText: 'Search sensors...',
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
                    heroTag: 'manage_sensors_search_close_fab',
                    onPressed: _toggleSearch,
                    child: Icon(
                      Icons.close,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  )
                else ...[
                  FloatingActionButton(
                    heroTag: 'manage_sensors_add_fab',
                    onPressed: () => _showCreateSensorDialog(context),
                    child: Icon(
                      Icons.add,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'manage_sensors_search_fab',
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

class SensorCard extends StatelessWidget {
  final SensorTypeList sensorType;

  const SensorCard({
    super.key,
    required this.sensorType,
  });

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextEditingController confirmController = TextEditingController();
    bool isLoading = false;
    final cubit = context.read<ManageSensorsCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ManageSensorsCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(
              'Delete Sensor Type',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This action cannot be undone. Please type "${sensorType.name}" to confirm.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    hintText: 'Type sensor name to confirm',
                    errorText: confirmController.text.isNotEmpty &&
                            confirmController.text != sensorType.name
                        ? 'Name does not match'
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ],
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
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
                        : colorScheme.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: isLoading ||
                        confirmController.text != sensorType.name
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        await cubit.deleteSensorType(sensorType.sensorTypeId);

                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                        // Show result in snackbar
                        final state = cubit.state;
                        if (state is DeleteSensorTypeSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sensor type deleted successfully'),
                            ),
                          );
                        } else if (state is DeleteSensorTypeError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.error,
                        ),
                      )
                    : Text(
                        'Delete',
                        style: TextStyle(
                          color: confirmController.text == sensorType.name
                              ? colorScheme.error
                              : colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditSensorDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextEditingController nameController =
        TextEditingController(text: sensorType.name);
    final TextEditingController functionController =
        TextEditingController(text: sensorType.function);
    bool isLoading = false;
    final cubit = context.read<ManageSensorsCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ManageSensorsCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(
              'Edit Sensor Type',
              style: theme.textTheme.titleLarge,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.sensors),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: functionController,
                  decoration: const InputDecoration(
                    labelText: 'Function',
                    prefixIcon: Icon(Icons.functions),
                  ),
                ),
              ],
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
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
                        : colorScheme.primary,
                  ),
                ),
              ),
              FilledButton(
                onPressed: isLoading ||
                        nameController.text.isEmpty ||
                        functionController.text.isEmpty
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        await cubit.createEditSensorType(
                          nameController.text,
                          functionController.text,
                          sensorType.sensorTypeId,
                        );

                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                        // Show result in snackbar
                        final state = cubit.state;
                        if (state is CreateEditSensorTypeSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sensor type updated successfully'),
                            ),
                          );
                          // Refresh the list
                          cubit.getAllSensorTypes();
                        } else if (state is CreateEditSensorTypeError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                          setState(() => isLoading = false);
                        }
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
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sensors,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sensorType.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${sensorType.sensorTypeId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditSensorDialog(context),
                  icon: Icon(
                    Icons.edit,
                    color: colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmationDialog(context),
                  icon: Icon(
                    Icons.delete,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Function',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sensorType.function,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
