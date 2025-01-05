import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/ui/screens/cloudhub_details_screen.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/monitoring/filter_button.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/monitoring/monitoring_dropdown.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/monitoring/sensors_table.dart';

class MonitoringScreen extends StatefulWidget {
  final int projectId;

  const MonitoringScreen({super.key, required this.projectId});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = "All";
  Monitoring? selectedMonitoring;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load default tab (Sensors)
    context.read<ProjectDashboardCubit>().getMonitoring(widget.projectId);
  }

  void _onTabChanged() {
    final cubit = context.read<ProjectDashboardCubit>();
    if (_tabController.index == 1) {
      cubit.getMonitoringCloudHub();
    } else if (_tabController.index == 0) {
      cubit.getMonitoring(widget.projectId);
    }
    // Add other tabs as needed
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
            builder: (context, state) {
              if (state is ProjectDashboardMonitoringLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProjectDashboardMonitoringSuccess) {
                final monitorings = state.monitoringResponse.monitorings ?? [];
                if (monitorings.isNotEmpty &&
                    (selectedMonitoring == null ||
                        !monitorings.contains(selectedMonitoring))) {
                  // Update the selectedMonitoring to the first valid item
                  selectedMonitoring = monitorings.first;
                }
                return Row(
                  children: [
                    Expanded(
                      child: MonitoringDropdownWidget(
                        selectedMonitoring: selectedMonitoring,
                        monitorings: monitorings,
                        onChanged: (newValue) {
                          setState(() {
                            selectedMonitoring = newValue;
                          });
                        },
                      ),
                    ),
                    // Show filter button only in the Sensors tab
                    if (_tabController.index == 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FilterButtonWidget(
                          selectedFilter: selectedFilter,
                          onFilterChanged: (newFilter) {
                            setState(() {
                              selectedFilter = newFilter;
                            });
                          },
                        ),
                      ),
                  ],
                );
              } else if (state is ProjectDashboardMonitoringFailure) {
                return Center(
                  child: Text(
                    "Error: ${state.message}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SensorsTab(
                  projectId: widget.projectId,
                  selectedFilter: selectedFilter,
                  selectedMonitoring: selectedMonitoring,
                ),
                const CloudHubTab(),
                const Center(child: Text("Alarms content")),
                const Center(child: Text("Data Source content")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Theme.of(context).primaryColor,
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      tabs: const [
        Tab(icon: Icon(Icons.sensors), text: "Sensors"),
        Tab(icon: Icon(Icons.cloud), text: "CloudHub"),
        Tab(icon: Icon(Icons.alarm), text: "Alarms"),
        Tab(icon: Icon(Icons.layers), text: "Data Source"),
      ],
    );
  }
}

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
        if (state is ProjectDashboardMonitoringLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProjectDashboardMonitoringSuccess) {
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
                            builder: (context) => CloudHubDetailsScreen(
                              cloudHub: state.cloudhubDetails,
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
