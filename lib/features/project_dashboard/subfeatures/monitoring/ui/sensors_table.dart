import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/sensor_data_model.dart'
    as sdm;
import 'package:pulsehub/features/project_dashboard/subfeatures/monitoring/ui/sensor_details_screen.dart';

class MonitoringTableWidget extends StatefulWidget {
  final Monitoring monitoring;
  final String selectedFilter;

  const MonitoringTableWidget({
    super.key,
    required this.monitoring,
    required this.selectedFilter,
  });

  @override
  State<MonitoringTableWidget> createState() => _MonitoringTableWidgetState();
}

class _MonitoringTableWidgetState extends State<MonitoringTableWidget> {
  final ScrollController _scrollController = ScrollController();
  static const int _itemsPerPage = 10;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  List<sdm.Sensor> _paginatedSensors = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreData();
    }
  }

  void _loadInitialData() {
    _currentPage = 0;
    _paginatedSensors = _getFilteredSensors().take(_itemsPerPage).toList();
    setState(() {});
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay

    final allFilteredSensors = _getFilteredSensors();
    final nextPageStart = (_currentPage + 1) * _itemsPerPage;

    if (nextPageStart < allFilteredSensors.length) {
      _currentPage++;
      final newItems =
          allFilteredSensors.skip(nextPageStart).take(_itemsPerPage).toList();

      setState(() {
        _paginatedSensors.addAll(newItems);
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  List<sdm.Sensor> _getFilteredSensors() {
    final filterMap = {
      "All": null,
      "Operational": "green",
      "Warning": "orange",
      "Critical": "red",
    };

    return (widget.monitoring.usedSensors ?? [])
        .expand((usedSensor) => (usedSensor.sensors ?? []).where((sensor) {
              final filterEvent = filterMap[widget.selectedFilter];
              if (filterEvent == null) return true;
              return sensor.event == filterEvent;
            }))
        .map((sensor) => sdm.Sensor(
              sensorId: sensor.sensorId,
              name: sensor.name,
              uuid: sensor.uuid,
              usedSensor: sensor.usedSensor,
              cloudHub: sensor.cloudHub,
              installDate: sensor.installDate,
              typeId: sensor.typeId,
              dataSource: sensor.dataSource,
              readingsPerDay: sensor.readingsPerDay,
              active: sensor.active,
              coordinateX: sensor.coordinateX,
              coordinateY: sensor.coordinateY,
              coordinateZ: sensor.coordinateZ,
              longitude: sensor.longitude,
              latitude: sensor.latitude,
              calibrated: sensor.calibrated,
              calibrationDate: sensor.calibrationDate,
              calibrationComments: sensor.calibrationComments,
              event: sensor.event ?? 'unknown',
              eventLastStatus: sensor.eventLastStatus ?? 'unknown',
              status: sensor.status ?? 'unknown',
              cloudHubTime: sensor.cloudHubTime,
              sendTime: sensor.sendTime,
            ))
        .toList();
  }

  @override
  void didUpdateWidget(MonitoringTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter != widget.selectedFilter ||
        oldWidget.monitoring != widget.monitoring) {
      _loadInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.monitoring.usedSensors ?? []).isEmpty) {
      return const Center(
        child: Text("No sensors available for this monitoring."),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 600,
                mainAxisExtent: 190,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _paginatedSensors.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _paginatedSensors.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final sensor = _paginatedSensors[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => sl<ProjectDashboardCubit>(),
                          child: SensorDetailsScreen(sensor: sensor),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section with Name and Status
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            border: Border(
                              left: BorderSide(
                                color: sensor.event == 'green'
                                    ? Colors.green
                                    : sensor.event == 'orange'
                                        ? Colors.orange
                                        : Colors.red,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sensor.name ?? 'Unknown Sensor',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          'UUID: ${sensor.uuid}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: sensor.active
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              sensor.active
                                                  ? Icons.power
                                                  : Icons.power_off,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              sensor.active
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: sensor.event == 'green'
                                              ? Colors.green
                                              : sensor.event == 'orange'
                                                  ? Colors.orange
                                                  : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              sensor.event == 'green'
                                                  ? Icons.check_circle
                                                  : sensor.event == 'orange'
                                                      ? Icons.warning
                                                      : Icons.error,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              sensor.event == 'green'
                                                  ? 'Operational'
                                                  : sensor.event == 'orange'
                                                      ? 'Warning'
                                                      : 'Critical',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Details Section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      'Data Source',
                                      sensor.dataSource?.toString() ?? 'N/A',
                                      Icons.data_usage,
                                      context: context,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Right Column
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      'Readings/Day',
                                      sensor.readingsPerDay?.toString() ??
                                          'N/A',
                                      Icons.speed,
                                      context: context,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(String? status) {
    final color = switch (status?.toLowerCase()) {
      'green' => Colors.green,
      'orange' => Colors.orange,
      'red' => Colors.red,
      _ => Colors.grey,
    };

    return Icon(Icons.circle, color: color, size: 12);
  }
}
