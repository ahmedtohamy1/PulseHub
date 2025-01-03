import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/special_widgets/chart_container.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/special_widgets/chart_data_editor.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/special_widgets/chart_types.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/special_widgets/table_container.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/special_widgets/table_data_editor.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/special_widgets/widget_type_selector.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SpecialWidgetsScreen extends StatefulWidget {
  const SpecialWidgetsScreen({super.key});

  @override
  State<SpecialWidgetsScreen> createState() => _SpecialWidgetsScreenState();
}

class _SpecialWidgetsScreenState extends State<SpecialWidgetsScreen> {
  // List to store the selected charts and their data
  final List<Map<String, dynamic>> _charts = [];
  final List<List<List<String>>> _tables = [];

  @override
  void initState() {
    super.initState();
    // Start with a default line chart
    _charts.add({
      'type': 'line',
      'data': _getDefaultDataForType('line'),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  ],
                ),
                ..._charts.map((chart) => ChartContainer(
                      type: chart['type'],
                      data: chart['data'],
                      onEdit: () => _showEditOptions(chart),
                      onDelete: () => _removeChart(_charts.indexOf(chart)),
                    )),
                ..._tables.asMap().entries.map((entry) => TableContainer(
                      data: entry.value,
                      onEdit: () => _editTableData(entry.key),
                      onDelete: () => _removeTable(entry.key),
                    )),
              ],
            ),
          ),
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
                }
              },
            ),
          ),
        ];
      },
    );
  }
}
