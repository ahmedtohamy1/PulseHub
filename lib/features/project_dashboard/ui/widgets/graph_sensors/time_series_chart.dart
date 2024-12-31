import 'dart:math';
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

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_hasDataForFields(
              ['accelX', 'accelY', 'accelZ', 'humidity', 'temperature']))
            _buildSectionTitle('Combined Sensor Data Over Time'),
          if (_hasDataForFields(
              ['accelX', 'accelY', 'accelZ', 'humidity', 'temperature']))
            _buildLineChart(
              _createCombinedOverTimeData(),
              isTimeXAxis: true,
              isMicroUnits: false,
              field: 'combined',
            ),
          if (_hasDataForFields(
              ['accelX', 'accelY', 'accelZ', 'humidity', 'temperature']))
            _buildSectionTitle('Combined Frequency-Magnitude'),
          if (_hasDataForFields(
              ['accelX', 'accelY', 'accelZ', 'humidity', 'temperature']))
            _buildLineChart(
              _createCombinedFreqMagnitudeData(),
              isTimeXAxis: false,
              isMicroUnits: true,
              field: 'combined',
            ),
          for (var field in [
            'accelX',
            'accelY',
            'accelZ',
            'humidity',
            'temperature'
          ]) ...[
            if (_hasDataForField(field))
              _buildSectionTitle('${_capitalize(field)} Over Time'),
            if (_hasDataForField(field))
              _buildLineChart(
                _createLineBarsData(field: field, byTime: true),
                isTimeXAxis: true,
                isMicroUnits: false,
                field: field,
              ),
            if (_hasDataForField(field))
              _buildSectionTitle('${_capitalize(field)} Over Frequency'),
            if (_hasDataForField(field))
              _buildLineChart(
                _createLineBarsData(field: field, byTime: false),
                isTimeXAxis: false,
                isMicroUnits: true,
                field: field,
              ),
          ],
        ],
      ),
    );
  }

  bool _hasDataForField(String field) {
    final result = data.result;
    if (result == null) return false;

    final dataForField = _getDataForField(result, field);
    if (dataForField == null ||
        dataForField.value == null ||
        dataForField.value!.isEmpty) {
      return false;
    }

    // Optionally, skip if *all* values are zero (or NaN):
    final allZero = dataForField.value!.every((v) => v == 0.0);
    if (allZero) {
      return false; // or keep true if you want to see a “flat line” at zero
    }

    return true;
  }

  bool _hasDataForFields(List<String> fields) {
    return fields.any((field) => _hasDataForField(field));
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLineChart(
    List<LineChartBarData> lineBarsData, {
    required bool isTimeXAxis,
    required bool isMicroUnits,
    String? field,
  }) {
    if (lineBarsData.isEmpty) {
      return const SizedBox.shrink();
    }

    final yScaleFactor = isMicroUnits ? 1e6 : 1.0;
    lineBarsData = _scaleLineBarsData(lineBarsData, yScaleFactor);

    // Calculate axis limits from the data
    var (minX, maxX, minY, maxY) =
        _calculateAxisLimits(lineBarsData, isTimeXAxis);

    if (minX == null || maxX == null || minY == null || maxY == null) {
      return const Center(child: Text('No valid data to display'));
    }

    // --- FIX 1: If we have a zero range (single point or constant data),
    //            force a minimal range so intervals won't be zero.
    if (minX == maxX) {
      minX = minX - 1;
      maxX = maxX + 1;
    }
    if (minY == maxY) {
      minY = minY - 1;
      maxY = maxY + 1;
    }

    // Now we can safely compute intervals
    double xInterval = (maxX - minX) / 4;
    double yInterval = (maxY - minY) / 4;

    // --- FIX 2: Just in case, avoid passing an interval of 0.0 to FLChart
    if (xInterval <= 0) xInterval = 1;
    if (yInterval <= 0) yInterval = 1;

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: true,
              horizontalInterval: yInterval,
              verticalInterval: xInterval,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 0.5,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 0.5,
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: xInterval,
                  getTitlesWidget: (value, meta) {
                    if (isTimeXAxis) {
                      final date =
                          DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      final hh = date.hour.toString().padLeft(2, '0');
                      final mm = date.minute.toString().padLeft(2, '0');
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('$hh:$mm',
                            style: const TextStyle(fontSize: 10)),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    final formattedValue = _formatValue(
                      value,
                      isTimeXAxis,
                      isMicroUnits,
                      field,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          formattedValue + (isMicroUnits ? ' µ' : ''),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.black12,
                width: 1,
              ),
            ),
            lineBarsData: lineBarsData,
            // Use the possibly adjusted axis values
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            clipData: const FlClipData.all(),
            backgroundColor: Colors.white,
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((spot) {
                    final xValue = isTimeXAxis
                        ? DateTime.fromMillisecondsSinceEpoch(spot.x.toInt())
                            .toString()
                        : spot.x.toStringAsFixed(2);
                    final yValue = spot.y.toStringAsFixed(2);
                    return LineTooltipItem(
                      '$field\nX: $xValue\nY: $yValue',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },
                tooltipPadding: const EdgeInsets.all(8),
                tooltipRoundedRadius: 8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _scaleLineBarsData(
      List<LineChartBarData> lineBarsData, double yScaleFactor) {
    return lineBarsData.map((barData) {
      final scaledSpots = barData.spots
          .map((spot) => FlSpot(spot.x, spot.y * yScaleFactor))
          .toList();
      return LineChartBarData(
        spots: scaledSpots,
        isCurved: false,
        color: barData.color,
        barWidth: 1.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3.5,
            color: barData.color!,
            strokeWidth: 1,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }

  (double?, double?, double?, double?) _calculateAxisLimits(
      List<LineChartBarData> lineBarsData, bool isTimeXAxis) {
    double? minX, maxX, minY, maxY;

    for (var barData in lineBarsData) {
      for (var spot in barData.spots) {
        minY = (minY == null || spot.y < minY) ? spot.y : minY;
        maxY = (maxY == null || spot.y > maxY) ? spot.y : maxY;
        minX = (minX == null || spot.x < minX) ? spot.x : minX;
        maxX = (maxX == null || spot.x > maxX) ? spot.x : maxX;
      }
    }

    if (!isTimeXAxis) {
      minY = 0;
    }

    return (minX, maxX, minY, maxY);
  }

  String _formatValue(
      double value, bool isTimeXAxis, bool isMicroUnits, String? field) {
    if (!isTimeXAxis && isMicroUnits) {
      return value.toStringAsFixed(1);
    } else if (isTimeXAxis && field?.startsWith('accel') == true) {
      return value.toStringAsFixed(4);
    } else if (isTimeXAxis) {
      return value.toStringAsFixed(2);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  List<LineChartBarData> _createCombinedOverTimeData() {
    return ['accelX', 'accelY', 'accelZ', 'humidity', 'temperature']
        .map((f) => _createLineBarsData(field: f, byTime: true))
        .expand((list) => list)
        .toList()
        .reversed
        .toList();
  }

  List<LineChartBarData> _createCombinedFreqMagnitudeData() {
    return ['accelX', 'accelY', 'accelZ', 'humidity', 'temperature']
        .map((f) => _createLineBarsData(field: f, byTime: false))
        .expand((list) => list)
        .toList()
        .reversed
        .toList();
  }

  List<LineChartBarData> _createLineBarsData({
    required String field,
    required bool byTime,
  }) {
    final result = data.result;
    if (result == null) return [];

    final color = _getColorForField(field);
    final (xValues, yValues) = _extractData(result, field, byTime);

    if (xValues.isEmpty || yValues.isEmpty) return [];

    final spots = List<FlSpot>.generate(
      min(xValues.length, yValues.length),
      (i) => FlSpot(xValues[i], yValues[i]),
    );

    return [
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      )
    ];
  }

  (List<double>, List<double>) _extractData(
      Result? result, String field, bool byTime) {
    List<double>? yValues;
    List<double>? xValues;

    if (result == null) return ([], []);

    if (byTime) {
      final data = _getDataForField(result, field);
      if (data != null) {
        yValues = data.value;
        xValues =
            data.time?.map((t) => t.millisecondsSinceEpoch.toDouble()).toList();
      }
    } else {
      final freqData = data.frequency?[field];
      final magData = data.magnitude?[field];

      if (freqData != null && magData != null) {
        xValues = freqData;
        yValues = magData;
      }
    }

    return (xValues ?? [], yValues ?? []);
  }

  Data? _getDataForField(Result result, String field) {
    switch (field) {
      case 'accelX':
        return result.accelX;
      case 'accelY':
        return result.accelY;
      case 'accelZ':
        return result.accelZ;
      case 'humidity':
        return result.humidity;
      case 'temperature':
        return result.temperature;
      default:
        return null;
    }
  }

  Color _getColorForField(String field) {
    switch (field) {
      case 'accelX':
        return Colors.blue;
      case 'accelY':
        return Colors.orange;
      case 'accelZ':
        return Colors.green;
      case 'humidity':
        return Colors.red;
      case 'temperature':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
