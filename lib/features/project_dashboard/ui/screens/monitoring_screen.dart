import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
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
  Monitoring? selectedMonitoring;
  late TabController _tabController;
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<ProjectDashboardCubit>().getMonitoring(widget.projectId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
            listener: (context, state) {
              if (state is ProjectDashboardMonitoringSuccess) {
                final monitorings = state.monitoringResponse.monitorings ?? [];
                if (monitorings.isNotEmpty) {
                  setState(() {
                    selectedMonitoring = monitorings
                        .first; // Set the first monitoring as default
                  });
                }
              }
            },
            child: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
              builder: (context, state) {
                if (state is ProjectDashboardMonitoringLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProjectDashboardMonitoringSuccess) {
                  final monitorings =
                      state.monitoringResponse.monitorings ?? [];
                  if (monitorings.isEmpty) {
                    return const Center(
                        child: Text("No monitorings available."));
                  }
                  return Column(
                    children: [
                      MonitoringDropdownWidget(
                        selectedMonitoring: selectedMonitoring,
                        monitorings: monitorings,
                        onChanged: (newValue) {
                          setState(() {
                            selectedMonitoring = newValue;
                          });
                        },
                      ),
                      _buildTabs(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            selectedMonitoring != null
                                ? SingleChildScrollView(
                                    child: MonitoringTableWidget(
                                      monitoring: selectedMonitoring!,
                                      selectedFilter: selectedFilter,
                                    ),
                                  )
                                : const Center(
                                    child: Text("No sensors available")),
                            const Center(child: Text("CloudHub content")),
                            const Center(child: Text("Alarms content")),
                            const Center(child: Text("Data Source content")),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (state is ProjectDashboardMonitoringFailure) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Center(child: Text("No data available"));
                }
              },
            ),
          ),
        ),
        FilterButtonWidget(
          selectedFilter: selectedFilter,
          onFilterChanged: (newFilter) {
            setState(() {
              selectedFilter = newFilter;
            });
          },
        ),
      ],
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
