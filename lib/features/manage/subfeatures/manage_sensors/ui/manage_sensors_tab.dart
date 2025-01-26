import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_sensors/ui/sensor_card.dart';

import '../cubit/manage_sensors_cubit.dart';

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
          // 1. Fixed state management for loading indicator
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
                  // 2. Removed unnecessary setState in onChanged
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: functionController,
                  decoration: const InputDecoration(
                    labelText: 'Function',
                    prefixIcon: Icon(Icons.functions),
                  ),
                  // 2. Removed unnecessary setState in onChanged
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                // 3. Simplified disabled state handling
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorScheme.primary),
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
                          null,
                        );

                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                        final state = cubit.state;
                        if (state is CreateEditSensorTypeSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sensor type created successfully'),
                            ),
                          );
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
                        child: CircularProgressIndicator(strokeWidth: 2),
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
