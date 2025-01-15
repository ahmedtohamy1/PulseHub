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
                    onPressed: () {
                      // TODO: Implement create functionality
                    },
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
                  onPressed: () {
                    // TODO: Implement edit functionality
                  },
                  icon: Icon(
                    Icons.edit,
                    color: colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement delete functionality
                  },
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
