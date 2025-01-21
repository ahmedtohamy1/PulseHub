import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/sensor_data_model.dart'
    as sdm;
import 'package:pulsehub/features/project_dashboard/subfeatures/monitoring/ui/sensor_details_screen.dart';

class MonitoringTableWidget extends StatelessWidget {
  final Monitoring monitoring;
  final String selectedFilter;

  const MonitoringTableWidget({
    super.key,
    required this.monitoring,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    if ((monitoring.usedSensors ?? []).isEmpty) {
      return const Center(
        child: Text("No sensors available for this monitoring."),
      );
    }

    final filterMap = {
      "All": null,
      "Operational": "green",
      "Warning": "orange",
      "Critical": "red",
    };

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600,
          mainAxisExtent: 210,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: (monitoring.usedSensors ?? [])
            .expand((usedSensor) => (usedSensor.sensors ?? []).where((sensor) {
                  final filterEvent = filterMap[selectedFilter];
                  if (filterEvent == null) return true;
                  return sensor.event == filterEvent;
                }))
            .length,
        itemBuilder: (context, index) {
          // Find the correct sensor for this index
          var currentIndex = 0;
          for (var usedSensor in (monitoring.usedSensors ?? [])) {
            for (var sensor in (usedSensor.sensors ?? [])) {
              final filterEvent = filterMap[selectedFilter];
              if (filterEvent == null || sensor.event == filterEvent) {
                if (currentIndex == index) {
                  return _buildSensorCard(context, usedSensor, sensor);
                }
                currentIndex++;
              }
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSensorCard(
      BuildContext context, UsedSensor usedSensor, Sensor sensor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              child: SensorDetailsScreen(
                sensor: sdm.Sensor(
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
                  event: sensor.event ?? 'N/A',
                  eventLastStatus: sensor.eventLastStatus ?? 'N/A',
                  status: sensor.status,
                  cloudHubTime: sensor.cloudHubTime,
                  sendTime: sensor.sendTime,
                ),
              ),
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
                color: colorScheme.primary.withValues(alpha: 0.1),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          usedSensor.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondary,
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
                          color: sensor.active ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              sensor.active ? Icons.power : Icons.power_off,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sensor.active ? 'Active' : 'Inactive',
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
                          borderRadius: BorderRadius.circular(12),
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
                          'Install Date',
                          sensor.installDate ?? 'N/A',
                          Icons.calendar_today,
                          context: context,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Data Source',
                          sensor.dataSource ?? 'N/A',
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
                          sensor.readingsPerDay?.toString() ?? 'N/A',
                          Icons.speed,
                          context: context,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Coordinates',
                          '${sensor.coordinateX ?? 'N/A'}, ${sensor.coordinateY ?? 'N/A'}, ${sensor.coordinateZ ?? 'N/A'}',
                          Icons.location_on,
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
            color: colorScheme.primary.withValues(alpha: 0.1),
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
}
