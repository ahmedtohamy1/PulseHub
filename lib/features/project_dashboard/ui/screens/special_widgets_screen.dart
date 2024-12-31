import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/special_widgets/chart_container.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/special_widgets/chart_data_editor.dart';
import 'package:pulsehub/features/project_dashboard/ui/widgets/special_widgets/chart_types.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SpecialWidgetsScreen extends StatefulWidget {
  const SpecialWidgetsScreen({super.key});

  @override
  State<SpecialWidgetsScreen> createState() => _SpecialWidgetsScreenState();
}

class _SpecialWidgetsScreenState extends State<SpecialWidgetsScreen> {
  // List to store the selected charts and their data
  final List<Map<String, dynamic>> _charts = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Back button at the top
                Row(
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.arrow_back_ios_new_outlined),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                // Display all selected charts
                for (var i = 0; i < _charts.length; i++)
                  ChartContainer(
                    type: _charts[i]['type'],
                    data: _charts[i]['data'],
                    onEdit: () => _editChartData(_charts[i]),
                    onDelete: () => _removeChart(i),
                  ),
              ],
            ),
          ),
        ),
        // Floating Action Button (FAB)
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _openGraphModalSheet(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  // Function to open Wolt Modal Sheet with chart type options
  void _openGraphModalSheet(BuildContext context) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: ChartTypes(
              onChartSelected: (type) {
                setState(() {
                  _charts.add({
                    'type': type,
                    'data': _getDefaultDataForType(type),
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        ];
      },
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
        return List.generate(
            5, (index) => RadarEntry(value: Random().nextDouble() * 5));
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

  // Function to edit chart data
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
    ).then((_) {
      // Ensure the parent widget rebuilds after the dialog is closed
      setState(() {});
    });
  }
}
