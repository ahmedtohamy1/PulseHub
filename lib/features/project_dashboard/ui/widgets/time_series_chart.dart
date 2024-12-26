import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';

class TimeSeriesChart extends StatelessWidget {
  final SensorDataResponse data;
  final List<String> selectedFields;

  const TimeSeriesChart({
    super.key,
    required this.data,
    required this.selectedFields,
  });

  @override
  Widget build(BuildContext context) {
    if (data.result == null) {
      return const Center(child: Text('No data available'));
    }

    final lineBarsData = _createLineBarsData();
    if (lineBarsData.isEmpty) {
      return const Center(child: Text('No data points to display'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    formatTimestamp(value.toInt()),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: lineBarsData,
        minX: lineBarsData.isEmpty ? 0 : lineBarsData.first.spots.first.x,
        maxX: lineBarsData.isEmpty ? 0 : lineBarsData.first.spots.last.x,
      ),
    );
  }

  String _mapFieldName(String field) {
    switch (field) {
      case 'acceleration_x':
        return 'accelX';
      case 'acceleration_y':
        return 'accelY';
      case 'acceleration_z':
        return 'accelZ';
      default:
        return field;
    }
  }

  List<LineChartBarData> _createLineBarsData() {
    final List<LineChartBarData> lineBarsData = [];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    var colorIndex = 0;
    final result = data.result;
    if (result == null) return [];

    for (var field in selectedFields) {
      final modelField = _mapFieldName(field);
      
      switch (modelField) {
        case 'accelX':
          if (result.accelX != null) {
            lineBarsData.add(_createLineChartBarData(
              result.accelX!.time!,
              result.accelX!.value!,
              colors[colorIndex++ % colors.length],
              field,
            ));
          }
          break;
        case 'accelY':
          if (result.accelY != null) {
            lineBarsData.add(_createLineChartBarData(
              result.accelY!.time!,
              result.accelY!.value!,
              colors[colorIndex++ % colors.length],
              field,
            ));
          }
          break;
        case 'accelZ':
          if (result.accelZ != null) {
            lineBarsData.add(_createLineChartBarData(
              result.accelZ!.time!,
              result.accelZ!.value!,
              colors[colorIndex++ % colors.length],
              field,
            ));
          }
          break;
        case 'humidity':
          if (result.humidity != null) {
            lineBarsData.add(_createLineChartBarData(
              result.humidity!.time!,
              result.humidity!.value!,
              colors[colorIndex++ % colors.length],
              field,
            ));
          }
          break;
        case 'temperature':
          if (result.temperature != null) {
            lineBarsData.add(_createLineChartBarData(
              result.temperature!.time!,
              result.temperature!.value!,
              colors[colorIndex % colors.length],
              field,
            ));
          }
          break;
      }
    }

    return lineBarsData;
  }

  LineChartBarData _createLineChartBarData(
    List<DateTime> times,
    List<double> values,
    Color color,
    String label,
  ) {
    final spots = <FlSpot>[];
    for (var i = 0; i < times.length; i++) {
      spots.add(FlSpot(
        times[i].millisecondsSinceEpoch.toDouble(),
        values[i],
      ));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
