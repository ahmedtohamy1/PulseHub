import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';

class MonitoringDropdownWidget extends StatelessWidget {
  final Monitoring? selectedMonitoring;
  final List<Monitoring> monitorings;
  final ValueChanged<Monitoring?> onChanged;

  const MonitoringDropdownWidget({
    super.key,
    required this.selectedMonitoring,
    required this.monitorings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (monitorings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No monitorings available',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            width: 5,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  topLeft: Radius.circular(8.0)),
            ),
          ),
          Text(
            selectedMonitoring?.name ?? 'Select Monitoring',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Monitoring>(
                value: selectedMonitoring,
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                onChanged: onChanged,
                items: monitorings
                    .map<DropdownMenuItem<Monitoring>>((Monitoring monitoring) {
                  return DropdownMenuItem<Monitoring>(
                    value: monitoring,
                    child: Text(
                      monitoring.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
