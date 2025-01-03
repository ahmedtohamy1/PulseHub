import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/time_series_chart.dart';

class TimeDbResponseBuilder extends StatelessWidget {
  const TimeDbResponseBuilder({
    super.key,
    required this.selectedFields,
  });

  final List<String> selectedFields;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      builder: (context, state) {
        if (state is ProjectDashboardDetailsTimeDbLoading) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading sensor data...'),
              ],
            ),
          );
        }

        if (state is ProjectDashboardDetailsTimeDbFailure) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (state is ProjectDashboardDetailsTimeDbSuccess) {
          if (state.sensorDataResponse.result == null) {
            return const Center(
              child:
                  Text('No sensor data available for the selected time range'),
            );
          }
          print(state.sensorDataResponse.dominate_frequencies);
          return TimeSeriesChart(
            data: state.sensorDataResponse,
            selectedFields: selectedFields,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
