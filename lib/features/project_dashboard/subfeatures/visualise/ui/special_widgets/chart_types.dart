import 'package:flutter/material.dart';

class ChartTypes extends StatelessWidget {
  final Function(String) onChartSelected;

  const ChartTypes({super.key, required this.onChartSelected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildChartTypeOption('Line Chart', 'line'),
        _buildChartTypeOption('Bar Chart', 'bar'),
        _buildChartTypeOption('Pie Chart', 'pie'),
        _buildChartTypeOption('Scatter Chart', 'scatter'),
        _buildChartTypeOption('Area Chart', 'area'),
        _buildChartTypeOption('Radar Chart', 'radar'),
      ],
    );
  }

  // Widget to build a chart type option
  Widget _buildChartTypeOption(String title, String type) {
    return ListTile(
      title: Text(title),
      onTap: () => onChartSelected(type),
    );
  }
}
