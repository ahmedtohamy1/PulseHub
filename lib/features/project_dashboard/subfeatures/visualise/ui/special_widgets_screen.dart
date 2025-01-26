import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_medial_library_response_model.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/cubit/visualise_cubit.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/special_widgets/chart_container.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/special_widgets/chart_data_editor.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/special_widgets/chart_types.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/special_widgets/table_container.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/special_widgets/table_data_editor.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/special_widgets/widget_type_selector.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SpecialWidgetsScreen extends StatefulWidget {
  final int projectId;
  final int dashboardId;
  final String dashboardName;
  const SpecialWidgetsScreen({
    super.key,
    required this.projectId,
    required this.dashboardId,
    required this.dashboardName,
  });

  @override
  State<SpecialWidgetsScreen> createState() => _SpecialWidgetsScreenState();
}

class _SpecialWidgetsScreenState extends State<SpecialWidgetsScreen> {
  // List to store the selected charts and their data
  final List<Map<String, dynamic>> _charts = [];
  final List<List<List<String>>> _tables = [];
  final List<Map<String, dynamic>> _sensorPlacements = [];
  late final VisualiseCubit _visualiseCubit;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _visualiseCubit = context.read<VisualiseCubit>();
    _loadDashboardComponents();
  }

  Future<void> _loadDashboardComponents() async {
    await _visualiseCubit.getImageWithSensors(widget.dashboardId);
    // After getting components, fetch media library
    await _visualiseCubit.getMediaLibrary(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<VisualiseCubit, VisualiseState>(
          listener: (context, state) {
            if (state is ImageWithSensorsLoading) {
              setState(() => _isLoading = true);
            } else if (state is ImageWithSensorsSuccess) {
              setState(() {
                // Clear existing components
                _charts.clear();
                _tables.clear();
                _sensorPlacements.clear();

                // Add components from the response
                final dashComponents = state.components;
                final components = dashComponents.dashboard.components;

                for (final component in components) {
                  if (component.name == "2D Sensor Placement" &&
                      component.content != null) {
                    // Add sensor placement component
                    _sensorPlacements.add({
                      'id': component.componentId,
                      'pictureName': component.content!.pictureName,
                      'sensors': component.content!.sensors,
                      'imageUrl':
                          null, // Will be populated when media library loads
                    });
                  } else if (component.content != null) {
                    // Add other components based on their type
                    _charts.add({
                      'type': 'line', // Default type, adjust based on content
                      'data': component.content,
                    });
                  }
                }
              });
            } else if (state is ImageWithSensorsFailure) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load components: ${state.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
        BlocListener<VisualiseCubit, VisualiseState>(
          listener: (context, state) {
            if (state is GetMediaLibrarySuccess) {
              setState(() {
                _isLoading = false;
                // Match media library files with sensor placements
                final mediaFiles = state.mediaLibraries.mediaLibraries ?? [];

                if (mediaFiles.isNotEmpty) {
                  for (var placement in _sensorPlacements) {
                    final pictureName = placement['pictureName'] as String;
                    MediaLibrary? matchingFile;

                    // First try exact match
                    try {
                      matchingFile = mediaFiles.firstWhere(
                        (file) => file.fileName == pictureName,
                      );
                    } catch (_) {
                      // Then try without 'scaled_' prefix
                      try {
                        matchingFile = mediaFiles.firstWhere(
                          (file) =>
                              file.fileName ==
                              pictureName.replaceAll('scaled_', ''),
                        );
                      } catch (_) {
                        // If no match found, use first file
                        matchingFile = mediaFiles.first;
                      }
                    }

                    placement['imageUrl'] = matchingFile.fileUrl;
                  }
                }
              });
            } else if (state is GetMediaLibraryFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load media: ${state.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filled(
                        icon: const Icon(Icons.arrow_back_ios_new_outlined),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      Text(widget.dashboardName,
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  if (_sensorPlacements.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '2D Sensor Placements',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._sensorPlacements.map((placement) => Card(
                          child: Column(
                            children: [
                              if (placement['imageUrl'] != null)
                                Image.network(
                                  placement['imageUrl']!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ListTile(
                                leading: const Icon(Icons.sensors),
                                title: Text(placement['pictureName']),
                                subtitle: Text(
                                    '${(placement['sensors'] as Map).length} sensors placed'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    context.push(
                                      Routes.imageSensorPlacing,
                                      extra: [
                                        widget.projectId,
                                        widget.dashboardId
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                  if (_charts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Charts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._charts.map((chart) => ChartContainer(
                          type: chart['type'],
                          data: chart['data'],
                          onEdit: () => _showEditOptions(chart),
                          onDelete: () => _removeChart(_charts.indexOf(chart)),
                        )),
                  ],
                  if (_tables.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Tables',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._tables.asMap().entries.map((entry) => TableContainer(
                          data: entry.value,
                          onEdit: () => _editTableData(entry.key),
                          onDelete: () => _removeTable(entry.key),
                        )),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => _openWidgetSelector(context),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  // Function to get default data for a chart type
  dynamic _getDefaultDataForType(String type) {
    switch (type) {
      case 'pie':
        return [40.0, 30.0, 30.0];
      case 'scatter':
      case 'area':
      case 'line':
      case 'bar':
        return List.generate(
            5, (index) => FlSpot(index.toDouble(), Random().nextDouble() * 5));
      case 'radar':
        return List.generate(5, (index) => Random().nextDouble() * 5);
      default:
        return [];
    }
  }

  // Function to remove a chart
  void _removeChart(int index) {
    setState(() {
      _charts.removeAt(index);
    });
  }

  void _showEditOptions(Map<String, dynamic> chart) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Chart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Data'),
                    onTap: () {
                      Navigator.pop(context);
                      _editChartData(chart);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Change Chart Type'),
                    onTap: () {
                      Navigator.pop(context);
                      _openChartTypeSelector(chart);
                    },
                  ),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }

  void _openChartTypeSelector(Map<String, dynamic> chart) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: ChartTypes(
              onChartSelected: (type) {
                setState(() {
                  chart['type'] = type;
                  chart['data'] = _getDefaultDataForType(type);
                });
                Navigator.pop(context);
              },
            ),
          ),
        ];
      },
    );
  }

  void _editChartData(Map<String, dynamic> chart) {
    final type = chart['type'];
    final data = chart['data'];

    showDialog(
      context: context,
      builder: (context) {
        return ChartDataEditor(
          type: type,
          data: data,
          onSave: (newData) {
            setState(() {
              chart['data'] = newData;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _editTableData(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return TableDataEditor(
          initialData: _tables[index],
          onSave: (newData) {
            setState(() {
              _tables[index] = newData;
            });
          },
        );
      },
    );
  }

  void _removeTable(int index) {
    setState(() {
      _tables.removeAt(index);
    });
  }

  List<List<String>> _getDefaultTableData() {
    return [
      ['Header 1', 'Header 2', 'Header 3'],
      ['Row 1, Cell 1', 'Row 1, Cell 2', 'Row 1, Cell 3'],
      ['Row 2, Cell 1', 'Row 2, Cell 2', 'Row 2, Cell 3'],
    ];
  }

  void _openWidgetSelector(BuildContext context) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: WidgetTypeSelector(
              onTypeSelected: (type) {
                Navigator.pop(context);
                if (type == 'chart') {
                  WoltModalSheet.show(
                    context: context,
                    pageListBuilder: (modalSheetContext) {
                      return [
                        WoltModalSheetPage(
                          child: ChartTypes(
                            onChartSelected: (selectedType) {
                              setState(() {
                                _charts.add({
                                  'type': selectedType,
                                  'data': _getDefaultDataForType(selectedType),
                                });
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ];
                    },
                  );
                } else if (type == 'table') {
                  setState(() {
                    _tables.add(_getDefaultTableData());
                  });
                } else if (type == 'image_sensor') {
                  // Navigate to image sensor placing screen
                  context.push(Routes.imageSensorPlacing,
                      extra: [widget.projectId, widget.dashboardId]);
                  Navigator.pop(context); // Close the modal sheet
                }
              },
            ),
          ),
        ];
      },
    );
  }
}
