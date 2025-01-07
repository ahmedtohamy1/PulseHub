import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/used_sensors_table.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart';

class CustomisationTab extends StatefulWidget {
  final Project project;
  const CustomisationTab({super.key, required this.project});

  @override
  State<CustomisationTab> createState() => _CustomisationTabState();
}

class _CustomisationTabState extends State<CustomisationTab> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final cubit = context.read<ProjectDashboardCubit>();
    await cubit.getUsedSensors();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      builder: (context, state) {
        if (state is ProjectDashboardGetUsedSensorsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectDashboardGetUsedSensorsFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ProjectDashboardGetUsedSensorsSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: UsedSensorsTable(
                  usedSensors:
                      state.getUsedSensorsResponseModel.usedSensorList ?? [],
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
