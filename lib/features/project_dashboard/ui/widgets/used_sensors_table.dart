import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_used_sensors_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart'
    as monitoring;
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/number_input.dart';

class UsedSensorsTable extends StatelessWidget {
  final List<UsedSensorList> usedSensors;
  final int projectId;

  const UsedSensorsTable({
    super.key,
    required this.usedSensors,
    required this.projectId,
  });

  Future<void> _showEditDialog(BuildContext context, UsedSensorList sensor) {
    final countController = TextEditingController(text: '${sensor.count ?? 0}');
    final cubit = context.read<ProjectDashboardCubit>();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (context, setState) {
            return BlocConsumer<ProjectDashboardCubit, ProjectDashboardState>(
              listenWhen: (previous, current) =>
                  current is ProjectDashboardUpdateUsedSensorsSuccess ||
                  current is ProjectDashboardUpdateUsedSensorsFailure,
              listener: (context, state) {
                if (state is ProjectDashboardUpdateUsedSensorsSuccess) {
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sensor count updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh the sensors list
                    context.read<ProjectDashboardCubit>().getUsedSensors();
                  }
                } else if (state is ProjectDashboardUpdateUsedSensorsFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Failed to update sensor count: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              buildWhen: (previous, current) =>
                  current is ProjectDashboardUpdateUsedSensorsLoading,
              builder: (context, state) {
                final isLoading =
                    state is ProjectDashboardUpdateUsedSensorsLoading;

                return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text(
                        'Edit Sensor Count',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: sensor.name ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: sensor.function ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Count',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      NumberInput(
                        label: '',
                        controller: countController,
                        onChanged: (value) {},
                        onIncrement: () {
                          final currentValue =
                              int.tryParse(countController.text) ?? 0;
                          countController.text = (currentValue + 1).toString();
                        },
                        onDecrement: () {
                          final currentValue =
                              int.tryParse(countController.text) ?? 0;
                          if (currentValue > 0) {
                            countController.text =
                                (currentValue - 1).toString();
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 80,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      FilledButton(
                        onPressed: () {
                          final newCount = int.tryParse(countController.text);
                          if (newCount != null && sensor.usedSensorId != null) {
                            final currentCount = sensor.count ?? 0;
                            final countDifference = newCount - currentCount;
                            context
                                .read<ProjectDashboardCubit>()
                                .updateUsedSensors(
                                    sensor.usedSensorId!, countDifference);
                          }
                        },
                        child: const Text('Save'),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, UsedSensorList sensor) {
    final TextEditingController confirmController = TextEditingController();
    bool isNameMatch = false;
    bool isLoading = false;

    // Capture the cubit before showing dialog
    final cubit = context.read<ProjectDashboardCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (context, setState) =>
              BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
            listenWhen: (previous, current) =>
                current is ProjectDashboardUpdateUsedSensorsSuccess ||
                current is ProjectDashboardUpdateUsedSensorsFailure,
            listener: (context, state) {
              if (state is ProjectDashboardUpdateUsedSensorsSuccess) {
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sensor deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Refresh the sensors list
                  cubit.getUsedSensors();
                }
              } else if (state is ProjectDashboardUpdateUsedSensorsFailure) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete sensor: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Delete Sensor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Are you sure you want to delete ',
                      style: const TextStyle(fontSize: 14),
                      children: [
                        TextSpan(
                          text: '"${sensor.name}"',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const TextSpan(text: '?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please type the sensor name to confirm deletion:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Enter sensor name',
                      border: const OutlineInputBorder(),
                      errorText:
                          confirmController.text.isNotEmpty && !isNameMatch
                              ? 'Name does not match'
                              : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        isNameMatch = value == sensor.name;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 80,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  FilledButton(
                    onPressed: isNameMatch
                        ? () {
                            setState(() => isLoading = true);
                            cubit.updateUsedSensors(
                                sensor.usedSensorId!, 0, true);
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      disabledBackgroundColor:
                          Theme.of(context).colorScheme.error.withOpacity(0.3),
                    ),
                    child: const Text('Delete'),
                  ),
              ],
            ),
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
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (context, setState) {
            return BlocConsumer<ProjectDashboardCubit, ProjectDashboardState>(
              listenWhen: (previous, current) =>
                  current is ProjectDashboardMonitoringSuccess ||
                  current is ProjectDashboardCreateUsedSensorsSuccess ||
                  current is ProjectDashboardCreateUsedSensorsFailure,
              listener: (context, state) {
                if (state is ProjectDashboardMonitoringSuccess) {
                  if (state.monitoringResponse.monitorings?.isNotEmpty ==
                      true) {
                    setState(() {
                      selectedMonitoring =
                          state.monitoringResponse.monitorings!.first;
                    });
                  }
                } else if (state is ProjectDashboardCreateUsedSensorsSuccess) {
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sensor added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh the sensors list
                    context.read<ProjectDashboardCubit>().getUsedSensors();
                  }
                } else if (state is ProjectDashboardCreateUsedSensorsFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add sensor: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              buildWhen: (previous, current) =>
                  current is ProjectDashboardMonitoringLoading ||
                  current is ProjectDashboardMonitoringSuccess ||
                  current is ProjectDashboardCreateUsedSensorsLoading,
              builder: (context, state) {
                final monitorings = state is ProjectDashboardMonitoringSuccess
                    ? state.monitoringResponse.monitorings ?? []
                    : <monitoring.Monitoring>[];
                final isLoading =
                    state is ProjectDashboardCreateUsedSensorsLoading;
                final isLoadingMonitoring =
                    state is ProjectDashboardMonitoringLoading;

                return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.sensors_outlined),
                      SizedBox(width: 8),
                      Text(
                        'Add New Sensor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monitoring',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isLoadingMonitoring)
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
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedMonitoring = value;
                                  });
                                },
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sensor Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  selectedSensorType = value;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Count',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      NumberInput(
                        label: '',
                        controller: countController,
                        onChanged: (value) {},
                        onIncrement: () {
                          final currentValue =
                              int.tryParse(countController.text) ?? 0;
                          countController.text = (currentValue + 1).toString();
                        },
                        onDecrement: () {
                          final currentValue =
                              int.tryParse(countController.text) ?? 0;
                          if (currentValue > 0) {
                            countController.text =
                                (currentValue - 1).toString();
                          }
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
                              // Refresh the sensors list when dialog is closed
                              context
                                  .read<ProjectDashboardCubit>()
                                  .getUsedSensors();
                            },
                      child: const Text('Cancel'),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 80,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      FilledButton(
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
                        child: const Text('Submit'),
                      ),
                  ],
                );
              },
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
                        onSelectChanged: (_) =>
                            _showEditDialog(context, sensor),
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
                                      _showDeleteDialog(context, sensor),
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
