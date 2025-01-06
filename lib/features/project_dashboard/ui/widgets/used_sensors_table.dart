import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_used_sensors_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart'
    as monitoring;

class UsedSensorsTable extends StatelessWidget {
  final List<UsedSensorList> usedSensors;
  final int projectId;

  const UsedSensorsTable({
    super.key,
    required this.usedSensors,
    required this.projectId,
  });

  Future<void> _showEditDialog(BuildContext context, UsedSensorList sensor) {
    final countController = TextEditingController(text: '');
    final cubit = context.read<ProjectDashboardCubit>();

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
          listener: (context, state) {
            if (state is ProjectDashboardUpdateUsedSensorsSuccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sensor count updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh the sensors list
              context.read<ProjectDashboardCubit>().getUsedSensors();
            } else if (state is ProjectDashboardUpdateUsedSensorsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Failed to update sensor count: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: AlertDialog(
            title: const Text('Edit Sensor Count'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'Sensor Type\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: sensor.name ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'Function\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: sensor.function ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: const [
                      TextSpan(
                        text: 'Count (New Sensors)\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: countController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 8),
                Text(
                  'Original Count: ${sensor.count ?? 0}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
                builder: (context, state) {
                  final isLoading =
                      state is ProjectDashboardUpdateUsedSensorsLoading;
                  return FilledButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final count = int.tryParse(countController.text);
                            if (count != null && sensor.usedSensorId != null) {
                              context
                                  .read<ProjectDashboardCubit>()
                                  .updateUsedSensors(
                                      sensor.usedSensorId!, count);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, UsedSensorList sensor) {
    final cubit = context.read<ProjectDashboardCubit>();

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
          listener: (context, state) {
            if (state is ProjectDashboardUpdateUsedSensorsSuccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sensor deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh the sensors list
              context.read<ProjectDashboardCubit>().getUsedSensors();
            } else if (state is ProjectDashboardUpdateUsedSensorsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete sensor: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: AlertDialog(
            title: const Text('Delete Sensor'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Are you sure you want to delete this sensor?'),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'Sensor Type: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: sensor.name ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'Function: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: sensor.function ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'Current Count: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: sensor.count?.toString() ?? '0'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
                builder: (context, state) {
                  final isLoading =
                      state is ProjectDashboardUpdateUsedSensorsLoading;
                  return FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (sensor.usedSensorId != null) {
                              context
                                  .read<ProjectDashboardCubit>()
                                  .updateUsedSensors(
                                      sensor.usedSensorId!, 0, true);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Delete'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddSensorDialog(BuildContext context) {
    final countController = TextEditingController(text: '1');
    final cubit = context.read<ProjectDashboardCubit>();
    String? selectedSensorType;
    monitoring.Monitoring? selectedMonitoring;

    // Fetch monitoring data when dialog opens
    cubit.getMonitoring(projectId);

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocConsumer<ProjectDashboardCubit, ProjectDashboardState>(
          listenWhen: (previous, current) =>
              current is ProjectDashboardMonitoringSuccess ||
              current is ProjectDashboardCreateUsedSensorsSuccess ||
              current is ProjectDashboardCreateUsedSensorsFailure,
          listener: (context, state) {
            if (state is ProjectDashboardMonitoringSuccess) {
              if (state.monitoringResponse.monitorings?.isNotEmpty == true) {
                selectedMonitoring =
                    state.monitoringResponse.monitorings!.first;
              }
            } else if (state is ProjectDashboardCreateUsedSensorsSuccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sensor added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh the sensors list
              context.read<ProjectDashboardCubit>().getUsedSensors();
            } else if (state is ProjectDashboardCreateUsedSensorsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to add sensor: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final monitorings = state is ProjectDashboardMonitoringSuccess
                ? state.monitoringResponse.monitorings ?? []
                : <monitoring.Monitoring>[];

            return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Add New Sensor'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monitoring',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (state is ProjectDashboardMonitoringLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      DropdownButtonFormField<monitoring.Monitoring>(
                        value: selectedMonitoring,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'Select Monitoring',
                        ),
                        items: monitorings.map((monitoring) {
                          return DropdownMenuItem(
                            value: monitoring,
                            child:
                                Text(monitoring.name ?? 'Unnamed Monitoring'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMonitoring = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sensor Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedSensorType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        hintText: 'Select Sensor Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'temperature',
                          child: Text('Temperature'),
                        ),
                        DropdownMenuItem(
                          value: 'humidity',
                          child: Text('Humidity'),
                        ),
                        DropdownMenuItem(
                          value: 'acceleration',
                          child: Text('Acceleration'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedSensorType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Count',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: countController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Refresh the sensors list when dialog is closed
                      context.read<ProjectDashboardCubit>().getUsedSensors();
                    },
                    child: const Text('Close'),
                  ),
                  BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
                    builder: (context, state) {
                      final isLoading =
                          state is ProjectDashboardCreateUsedSensorsLoading;
                      return FilledButton(
                        onPressed: selectedSensorType == null ||
                                selectedMonitoring == null
                            ? null
                            : () {
                                final count =
                                    int.tryParse(countController.text);
                                if (count != null) {
                                  final sensorTypeMap = {
                                    'temperature': 2,
                                    'humidity': 3,
                                    'acceleration': 1,
                                  };
                                  final sensorTypeId =
                                      sensorTypeMap[selectedSensorType];
                                  if (sensorTypeId != null) {
                                    context
                                        .read<ProjectDashboardCubit>()
                                        .createUsedSensors(
                                          sensorTypeId,
                                          count,
                                          selectedMonitoring!.monitoringId,
                                        );
                                  }
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Submit'),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Monitoring Sensor Types',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            IconButton.filled(
              tooltip: 'Add new sensor',
              icon: const Icon(Icons.sensors),
              onPressed: () => _showAddSensorDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (usedSensors.isEmpty)
          const Expanded(
            child: Center(
              child: Text("No sensors available."),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStateColor.resolveWith(
                        (states) => Theme.of(context).colorScheme.primary),
                    columns: const [
                      DataColumn(
                          label: Text('Sensor Name',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Function',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Count',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Actions',
                              style: TextStyle(color: Colors.white))),
                    ],
                    rows: List.generate(usedSensors.length, (index) {
                      final sensor = usedSensors[index];
                      final rowColor = index % 2 == 0
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.surface;

                      return DataRow(
                        color:
                            WidgetStateColor.resolveWith((states) => rowColor),
                        cells: [
                          DataCell(Text(sensor.name ?? 'N/A')),
                          DataCell(Text(sensor.function ?? 'N/A')),
                          DataCell(Text(sensor.count?.toString() ?? '0')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(4),
                                    minimumSize: const Size(32, 32),
                                  ),
                                  onPressed: () =>
                                      _showEditDialog(context, sensor),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_forever,
                                      size: 18),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(4),
                                    minimumSize: const Size(32, 32),
                                  ),
                                  onPressed: () =>
                                      _showDeleteConfirmationDialog(
                                          context, sensor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
