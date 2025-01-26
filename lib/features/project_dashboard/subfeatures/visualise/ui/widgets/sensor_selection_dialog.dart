import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';

class SensorSelectionDialog extends StatefulWidget {
  final int projectId;
  final List<String> placedSensorIds;
  const SensorSelectionDialog({
    super.key,
    required this.projectId,
    required this.placedSensorIds,
  });

  @override
  State<SensorSelectionDialog> createState() => _SensorSelectionDialogState();
}

class _SensorSelectionDialogState extends State<SensorSelectionDialog> {
  String? selectedSensorId;

  @override
  void initState() {
    super.initState();
    // Get all available sensors
    context.read<ProjectDashboardCubit>().getMonitoring(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.sensors_outlined,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text('Select a Sensor'),
        ],
      ),
      content: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
        builder: (context, state) {
          if (state is ProjectDashboardMonitoringLoading) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProjectDashboardMonitoringFailure) {
            return SizedBox(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load sensors: ${state.message}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProjectDashboardMonitoringSuccess) {
            final monitorings = state.monitoringResponse.monitorings ?? [];

            if (monitorings.isEmpty) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sensors_off,
                        color: colorScheme.secondary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No sensors available',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Select a sensor to place on the image:',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: monitorings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final monitoring = monitorings[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            collapsedBackgroundColor: colorScheme.surface,
                            backgroundColor:
                                colorScheme.primaryContainer.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            title: Text(
                              monitoring.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'ID: ${monitoring.monitoringId}',
                              style: TextStyle(
                                color: colorScheme.secondary,
                                fontSize: 12,
                              ),
                            ),
                            leading: Icon(
                              Icons.monitor_heart_outlined,
                              color: colorScheme.primary,
                            ),
                            children: [
                              if (monitoring.usedSensors == null ||
                                  monitoring.usedSensors!.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.sensors_off,
                                        color: colorScheme.secondary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('No sensors available'),
                                    ],
                                  ),
                                )
                              else
                                ...monitoring.usedSensors!.expand(
                                  (usedSensor) =>
                                      usedSensor.sensors?.map(
                                        (sensor) => RadioListTile(
                                          value: sensor.sensorId.toString(),
                                          groupValue: selectedSensorId,
                                          onChanged: (sensor.cloudHub != null ||
                                                  widget.placedSensorIds
                                                      .contains(sensor.sensorId
                                                          .toString()))
                                              ? null
                                              : (value) {
                                                  setState(() {
                                                    selectedSensorId =
                                                        value as String;
                                                  });
                                                },
                                          title: Text(sensor.name),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('UUID: ${sensor.uuid}'),
                                              Row(
                                                children: [
                                                  Icon(
                                                    sensor.active
                                                        ? Icons.check_circle
                                                        : Icons.cancel,
                                                    size: 12,
                                                    color: sensor.active
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    sensor.active
                                                        ? 'Active'
                                                        : 'Inactive',
                                                    style: TextStyle(
                                                      color: sensor.active
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                  if (sensor.cloudHub !=
                                                      null) ...[
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      Icons.cloud,
                                                      size: 12,
                                                      color: colorScheme.error,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Already assigned',
                                                      style: TextStyle(
                                                        color:
                                                            colorScheme.error,
                                                      ),
                                                    ),
                                                  ],
                                                  if (widget.placedSensorIds
                                                      .contains(sensor.sensorId
                                                          .toString())) ...[
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      Icons.place,
                                                      size: 12,
                                                      color: colorScheme.error,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Already placed',
                                                      style: TextStyle(
                                                        color:
                                                            colorScheme.error,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ) ??
                                      [],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: colorScheme.secondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: selectedSensorId == null
              ? null
              : () {
                  Navigator.pop(context, selectedSensorId);
                },
          child: const Text('Place Sensor'),
        ),
      ],
    );
  }
}
