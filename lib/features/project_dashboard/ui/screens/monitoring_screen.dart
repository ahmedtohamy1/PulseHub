import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/monitoring/cloud_hub_tab.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/monitoring/filter_button.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/monitoring/monitoring_dropdown.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/monitoring/sensors_tab.dart';

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
              if (state is ProjectDashboardMonitoringSuccess) {
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
              }
              return const SizedBox.shrink();
            },
          ),
          _buildTabs(),
          Expanded(
            child: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
              builder: (context, state) {
                if (state is ProjectDashboardMonitoringLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TabBarView(
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
                );
              },
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
      labelColor: Theme.of(context).tabBarTheme.labelColor,
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
