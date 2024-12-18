import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';

class DashboardCard extends StatelessWidget {
  final Dashboard dashboard;

  const DashboardCard({required this.dashboard, super.key});

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, HH:mm:ss').format(dateTime);
    } catch (_) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dashboard.name.isNotEmpty ? dashboard.name : 'Unnamed Dashboard',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              dashboard.description.isNotEmpty
                  ? dashboard.description
                  : 'No description provided',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4.0),
                Text(
                  'Last Edited: ${_formatDate(dashboard.lastEdition)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
