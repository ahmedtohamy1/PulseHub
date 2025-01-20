import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/monitoring/ui/cloudhub_details_screen.dart';

class CloudHubTab extends StatefulWidget {
  const CloudHubTab({super.key});

  @override
  State<CloudHubTab> createState() => _CloudHubTabState();
}

class _CloudHubTabState extends State<CloudHubTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Preserve the state of this tab

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      builder: (context, state) {
        final cubit = context.read<ProjectDashboardCubit>();

        // Use the stored monitoringCloudHubResponse if available
        if (cubit.monitoringCloudHubResponse != null) {
          final cloudHubs = cubit.monitoringCloudHubResponse!.cloudhubs ?? [];
          if (cloudHubs.isEmpty) {
            return const Center(child: Text("No CloudHubs available."));
          }
          return _buildCloudHubTable(cloudHubs);
        }

        // Handle loading and error states
        if (state is ProjectDashboardMonitoringCloudHubLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProjectDashboardMonitoringCloudHubFailure) {
          return Center(
            child: Text(
              "Error: ${state.message}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          return const Center(child: Text("No CloudHub data available."));
        }
      },
    );
  }

  Widget _buildCloudHubTable(List<CloudHub> cloudHubs) {
    int globalIndex = 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Horizontal scrolling for the table
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Vertical scrolling for the rows
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            width: MediaQuery.of(context)
                .size
                .width, // Set the width to the screen width
            child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => Theme.of(context).primaryColor,
              ),
              columns: const [
                DataColumn(
                    label: Text('Name', style: TextStyle(color: Colors.white))),
                DataColumn(
                    label:
                        Text('Notes', style: TextStyle(color: Colors.white))),
                DataColumn(
                    label: Text('Code', style: TextStyle(color: Colors.white))),
              ],
              rows: cloudHubs.map((cloudHub) {
                final rowColor = globalIndex % 2 == 0
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surface;

                globalIndex++;

                return DataRow(
                  color: WidgetStateColor.resolveWith((states) => rowColor),
                  cells: [
                    DataCell(Text(cloudHub.name)),
                    DataCell(Text(cloudHub.notes ?? 'N/A')),
                    DataCell(Text(cloudHub.code ?? 'N/A')),
                  ],
                  onSelectChanged: (_) {
                    // Fetch CloudHub details and navigate to the details screen
                    context
                        .read<ProjectDashboardCubit>()
                        .getCloudhubData(cloudHub.cloudhubId)
                        .then((_) {
                      final state = context.read<ProjectDashboardCubit>().state;
                      if (state is ProjectDashboardCloudhubDataSuccess) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => sl<ProjectDashboardCubit>(),
                              child: CloudHubDetailsScreen(
                                cloudHub: state.cloudhubDetails,
                              ),
                            ),
                          ),
                        );
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
