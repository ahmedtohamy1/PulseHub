import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';

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
  String selectedFilter = "All"; // Default filter value

  Offset buttonPosition =
      const Offset(16, 16); // Initial position of the button

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<ProjectDashboardCubit>().getMonitoring(widget.projectId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<ProjectDashboardCubit>().state;
      if (state is ProjectDashboardMonitoringSuccess) {
        final monitorings = state.monitoringResponse.monitorings ?? [];
        if (monitorings.isNotEmpty) {
          setState(() {
            selectedMonitoring = monitorings.first;
          });
        }
      }
    });
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
          body: BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
            builder: (context, state) {
              if (state is ProjectDashboardMonitoringLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProjectDashboardMonitoringSuccess) {
                final monitorings = state.monitoringResponse.monitorings ?? [];
                if (monitorings.isEmpty) {
                  return const Center(child: Text("No monitorings available."));
                }
                return Column(
                  children: [
                    _buildStyledMonitoringDropdown(monitorings),
                    _buildTabs(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Sensors Tab with the table
                          selectedMonitoring != null
                              ? SingleChildScrollView(
                                  child: _buildMonitoringTable(
                                      selectedMonitoring!),
                                )
                              : const Center(
                                  child: Text("No sensors available")),
                          // CloudHub Tab
                          const Center(child: Text("CloudHub content")),
                          // Alarms Tab
                          const Center(child: Text("Alarms content")),
                          // Data Source Tab
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
        // Draggable floating filter button
        Positioned(
          top: buttonPosition.dy,
          left: buttonPosition.dx,
          child: Draggable(
            feedback: _buildFilterButton(),
            childWhenDragging: Container(), // Placeholder when dragging
            onDragEnd: (details) {
              final screenSize = MediaQuery.of(context).size;
              const buttonSize = 56.0; // Default FAB size
              const bottomMargin = 80.0; // Minimum distance from bottom

              setState(() {
                // Clamp the button position within the screen bounds, keeping a bottom margin
                buttonPosition = Offset(
                  details.offset.dx.clamp(0.0, screenSize.width - buttonSize),
                  details.offset.dy.clamp(
                      0.0, screenSize.height - buttonSize - bottomMargin),
                );
              });
            },
            child: _buildFilterButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledMonitoringDropdown(List<Monitoring> monitorings) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            width: 5,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  topLeft: Radius.circular(8.0)),
            ),
          ),
          Text(
            selectedMonitoring?.name ?? 'Select Monitoring',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Monitoring>(
                value: selectedMonitoring ?? monitorings.first,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                style: const TextStyle(color: Colors.green, fontSize: 16),
                onChanged: (Monitoring? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedMonitoring = newValue;
                    });
                  }
                },
                items: monitorings.map((Monitoring monitoring) {
                  return DropdownMenuItem<Monitoring>(
                    value: monitoring,
                    child: Text(monitoring.name),
                  );
                }).toList(),
              ),
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

  Widget _buildMonitoringTable(Monitoring monitoring) {
    if ((monitoring.usedSensors ?? []).isEmpty) {
      return const Center(
        child: Text("No sensors available for this monitoring."),
      );
    }

    // Map filter values to sensor event types
    final filterMap = {
      "All": null,
      "Operational": "green",
      "Warning": "orange",
      "Critical": "red",
    };

    int globalIndex = 0; // Initialize a global row index

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
            (states) => Theme.of(context).primaryColor,
          ),
          columns: const [
            DataColumn(
                label: Text('Category', style: TextStyle(color: Colors.white))),
            DataColumn(
                label:
                    Text('Sensor Name', style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Install Date',
                    style: TextStyle(color: Colors.white))),
            DataColumn(
                label:
                    Text('Data Source', style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Readings/Day',
                    style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Active', style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Event', style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Calibration D.',
                    style: TextStyle(color: Colors.white))),
            DataColumn(
                label:
                    Text('Coordinates', style: TextStyle(color: Colors.white))),
          ],
          rows: (monitoring.usedSensors ?? []).expand((usedSensor) {
            return (usedSensor.sensors ?? []).where((sensor) {
              final filterEvent = filterMap[selectedFilter];
              if (filterEvent == null)
                return true; // Show all if "All" is selected
              return sensor.event == filterEvent; // Match specific filter
            }).map((sensor) {
              final rowColor = globalIndex % 2 == 0
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.surface;

              globalIndex++; // Increment global index for each row

              return DataRow(
                color: WidgetStateColor.resolveWith((states) => rowColor),
                cells: [
                  DataCell(Text(usedSensor.name)),
                  DataCell(Text(sensor.name)),
                  DataCell(Text(sensor.installDate ?? 'N/A')),
                  DataCell(Text(sensor.dataSource ?? 'N/A')),
                  DataCell(Text(sensor.readingsPerDay?.toString() ?? 'N/A')),
                  DataCell(Text(sensor.active ? 'Yes' : 'No')),
                  DataCell(
                    Row(
                      children: [
                        Icon(
                          sensor.event == 'green'
                              ? Icons.check_circle
                              : sensor.event == 'orange'
                                  ? Icons.warning
                                  : Icons.error,
                          color: sensor.event == 'green'
                              ? Colors.green
                              : sensor.event == 'orange'
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sensor.event == 'green'
                              ? 'Operational'
                              : sensor.event == 'orange'
                                  ? 'Warning'
                                  : 'Critical',
                          style: TextStyle(
                            color: sensor.event == 'green'
                                ? Colors.green
                                : sensor.event == 'orange'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(sensor.calibrationDate ?? 'N/A')),
                  DataCell(Text(
                      '${sensor.coordinateX ?? 'N/A'}, ${sensor.coordinateY ?? 'N/A'}, ${sensor.coordinateZ ?? 'N/A'}')),
                ],
              );
            }).toList();
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return FloatingActionButton(
      onPressed: () {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            buttonPosition.dx,
            buttonPosition.dy,
            MediaQuery.of(context).size.width - buttonPosition.dx - 56,
            MediaQuery.of(context).size.height - buttonPosition.dy - 56,
          ),
          items: [
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.public, color: Colors.blue),
                title: const Text("All"),
                onTap: () {
                  setState(() {
                    selectedFilter = "All";
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text("Operational"),
                onTap: () {
                  setState(() {
                    selectedFilter = "Operational";
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text("Warning"),
                onTap: () {
                  setState(() {
                    selectedFilter = "Warning";
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: const Text("Critical"),
                onTap: () {
                  setState(() {
                    selectedFilter = "Critical";
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
      backgroundColor: Colors.green,
      child: const Icon(Icons.filter_list, color: Colors.white),
    );
  }
}
