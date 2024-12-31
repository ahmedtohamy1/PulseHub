import 'package:flutter/material.dart';
import 'chart_builders.dart'; // Reusable chart builders

class ChartContainer extends StatelessWidget {
  final String type;
  final dynamic data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChartContainer({
    super.key,
    required this.type,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getChartTitle(type),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildChart(type, data),
            ),
          ],
        ),
      ),
    );
  }

  // Function to get the chart title based on type
  String _getChartTitle(String type) {
    switch (type) {
      case 'line':
        return 'Line Chart';
      case 'bar':
        return 'Bar Chart';
      case 'pie':
        return 'Pie Chart';
      case 'scatter':
        return 'Scatter Chart';
      case 'area':
        return 'Area Chart';
      case 'radar':
        return 'Radar Chart';
      default:
        return 'Chart';
    }
  }

  // Function to build the chart based on type
  Widget _buildChart(String type, dynamic data) {
    switch (type) {
      case 'line':
        return buildLineChart(data);
      case 'bar':
        return buildBarChart(data);
      case 'pie':
        return buildPieChart(data);
      case 'scatter':
        return buildScatterChart(data);
      case 'area':
        return buildAreaChart(data);
      case 'radar':
        return buildRadarChart(data);
      default:
        return const Center(child: Text('Unsupported chart type'));
    }
  }
}
