import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/graph_sensors/time_series_chart.dart';

class TimeDbResponseBuilder extends StatelessWidget {
  const TimeDbResponseBuilder({
    super.key,
    required this.selectedFields,
    required this.onAnalyzeSensor,
    required this.windowSize,
    required this.deviationThreshold,
    required this.timeRange,
    required this.isCustomRange,
    required this.customRangeController,
    required this.aggregateFunction,
    required this.windowPeriod,
    required this.selectedMeasurement,
    required this.selectedTopic,
  });

  final List<String> selectedFields;
  final String windowSize;
  final String deviationThreshold;
  final String timeRange;
  final bool isCustomRange;
  final TextEditingController customRangeController;
  final String aggregateFunction;
  final String windowPeriod;
  final String? selectedMeasurement;
  final String? selectedTopic;
  final Function(String field) onAnalyzeSensor;

  void _analyzeSensor(BuildContext context, String field) {
    if (selectedMeasurement == null || selectedTopic == null) return;

    onAnalyzeSensor(field);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      buildWhen: (previous, current) =>
          current is ProjectDashboardDetailsTimeDbLoading ||
          current is ProjectDashboardDetailsTimeDbSuccess ||
          current is ProjectDashboardDetailsTimeDbFailure,
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
          return TimeSeriesChart(
            data: state.sensorDataResponse,
            selectedFields: selectedFields,
            onAnalyze: (field) => _analyzeSensor(context, field),
          );
        }

        final cubit = context.read<ProjectDashboardCubit>();
        if (cubit.lastTimeDbResponse != null) {
          return TimeSeriesChart(
            data: cubit.lastTimeDbResponse!,
            selectedFields: selectedFields,
            onAnalyze: (field) => _analyzeSensor(context, field),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
