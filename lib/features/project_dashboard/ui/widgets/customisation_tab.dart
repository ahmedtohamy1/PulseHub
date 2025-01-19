import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_used_sensors_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart'
    as monitoring;
import 'package:pulsehub/features/project_dashboard/ui/widgets/used_sensors_table.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

class CustomisationTab extends StatefulWidget {
  final Project project;
  const CustomisationTab({super.key, required this.project});

  @override
  State<CustomisationTab> createState() => _CustomisationTabState();
}

class _CustomisationTabState extends State<CustomisationTab> {
  List<monitoring.Monitoring>? _monitorings;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final cubit = context.read<ProjectDashboardCubit>();
    await cubit.getUsedSensors();
    await cubit.getMonitoring(widget.project.projectId!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectDashboardCubit, ProjectDashboardState>(
      listenWhen: (previous, current) =>
          current is ProjectDashboardMonitoringSuccess,
      listener: (context, state) {
        if (state is ProjectDashboardMonitoringSuccess) {
          setState(() {
            _monitorings = state.monitoringResponse.monitorings;
          });
        }
      },
      buildWhen: (previous, current) =>
          current is ProjectDashboardGetUsedSensorsLoading ||
          current is ProjectDashboardGetUsedSensorsFailure ||
          current is ProjectDashboardGetUsedSensorsSuccess,
      builder: (context, state) {
        if (state is ProjectDashboardGetUsedSensorsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectDashboardGetUsedSensorsFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ProjectDashboardGetUsedSensorsSuccess) {
          // Filter sensors based on project's monitoring groups
          final List<UsedSensorList> allSensors =
              state.getUsedSensorsResponseModel.usedSensorList ?? [];
          final List<UsedSensorList> filteredSensors = _monitorings != null
              ? allSensors
                  .where(
                    (sensor) => _monitorings!.any(
                      (monitoring) =>
                          monitoring.project == widget.project.projectId &&
                          sensor.monitoring == monitoring.monitoringId,
                    ),
                  )
                  .toList()
              : [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: UsedSensorsTable(
                  usedSensors: filteredSensors,
                  projectId: widget.project.projectId!,
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('No data available'));
      },
    );
  }
}
