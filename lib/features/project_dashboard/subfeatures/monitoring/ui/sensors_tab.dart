import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/monitoring/ui/sensors_table.dart';

class SensorsTab extends StatefulWidget {
  final int projectId;
  final String selectedFilter;
  final Monitoring? selectedMonitoring;

  const SensorsTab({
    super.key,
    required this.projectId,
    required this.selectedFilter,
    required this.selectedMonitoring,
  });

  @override
  State<SensorsTab> createState() => _SensorsTabState();
}

class _SensorsTabState extends State<SensorsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Preserve the state of this tab

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      builder: (context, state) {
        if (state is ProjectDashboardMonitoringSuccess) {
          final monitorings = state.monitoringResponse.monitorings ?? [];
          if (monitorings.isEmpty) {
            return const Center(child: Text("No sensors available."));
          }
          return MonitoringTableWidget(
            monitoring: widget.selectedMonitoring ?? monitorings.first,
            selectedFilter: widget.selectedFilter,
          );
        } else {
          return const Center(child: Text("No data available"));
        }
      },
    );
  }
}
