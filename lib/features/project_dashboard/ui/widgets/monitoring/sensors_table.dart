import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';

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

    int globalIndex = 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
            (states) => Theme.of(context).primaryColor,
          ),
          columns: const [
            DataColumn(
                label: Text('Category', style: TextStyle(color: Colors.white))),
            DataColumn(
                label:
                    Text('Sensor Name', style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Install Date',
                    style: TextStyle(color: Colors.white))),
            DataColumn(
                label:
                    Text('Data Source', style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Readings/Day',
                    style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Active', style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Event', style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Calibration D.',
                    style: TextStyle(color: Colors.white))),
            DataColumn(
                label:
                    Text('Coordinates', style: TextStyle(color: Colors.white))),
          ],
          rows: (monitoring.usedSensors ?? []).expand((usedSensor) {
            return (usedSensor.sensors ?? []).where((sensor) {
              final filterEvent = filterMap[selectedFilter];
              if (filterEvent == null) {
                return true;
              }
              return sensor.event == filterEvent;
            }).map((sensor) {
              final rowColor = globalIndex % 2 == 0
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.surface;

              globalIndex++;

              return DataRow(
                color: WidgetStateColor.resolveWith((states) => rowColor),
                cells: [
                  DataCell(Text(usedSensor.name)),
                  DataCell(Text(sensor.name)),
                  DataCell(Text(sensor.installDate ?? 'N/A')),
                  DataCell(Text(sensor.dataSource ?? 'N/A')),
                  DataCell(Text(sensor.readingsPerDay?.toString() ?? 'N/A')),
                  DataCell(Text(sensor.active ? 'Yes' : 'No')),
                  DataCell(
                    Row(
                      children: [
                        Icon(
                          sensor.event == 'green'
                              ? Icons.check_circle
                              : sensor.event == 'orange'
                                  ? Icons.warning
                                  : Icons.error,
                          color: sensor.event == 'green'
                              ? Colors.green
                              : sensor.event == 'orange'
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sensor.event == 'green'
                              ? 'Operational'
                              : sensor.event == 'orange'
                                  ? 'Warning'
                                  : 'Critical',
                          style: TextStyle(
                            color: sensor.event == 'green'
                                ? Colors.green
                                : sensor.event == 'orange'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(sensor.calibrationDate ?? 'N/A')),
                  DataCell(Text(
                      '${sensor.coordinateX ?? 'N/A'}, ${sensor.coordinateY ?? 'N/A'}, ${sensor.coordinateZ ?? 'N/A'}')),
                ],
              );
            }).toList();
          }).toList(),
        ),
      ),
    );
  }
}
