import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';

class DashboardCard extends StatelessWidget {
  final VoidCallback onTap;
  final Dashboard dashboard;
  final int projectId;

  const DashboardCard({
    required this.dashboard,
    required this.onTap,
    required this.projectId,
    super.key,
  });

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
    final cubit = context.read<ProjectDashboardCubit>();

    return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
      listener: (context, state) {
        if (state is ProjectDashboardDeleteDashSuccess) {
          // Refresh the dashboards list
          cubit.getDashs(projectId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dashboard deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProjectDashboardDeleteDashFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete dashboard: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dashboard.name.isNotEmpty
                            ? dashboard.name
                            : 'Unnamed Dashboard',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => BlocProvider.value(
                            value: cubit,
                            child: AlertDialog(
                              title: const Text('Delete Dashboard'),
                              content: Text(
                                  'Are you sure you want to delete "${dashboard.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<ProjectDashboardCubit>()
                                        .deleteDash(dashboard.dashboardId);
                                    Navigator.pop(dialogContext);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
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
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
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
        ),
      ),
    );
  }
}
