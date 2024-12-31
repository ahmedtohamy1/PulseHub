import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Line Chart
Widget buildLineChart(List<FlSpot> data) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
    child: LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.black12,
            width: 1,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: false,
            color: Colors.blue,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        minX: 0,
        maxX: data.isNotEmpty ? data.last.x : 5,
        minY: 0,
        maxY: data.isNotEmpty
            ? data.map((e) => e.y).reduce((a, b) => a > b ? a : b)
            : 5,
        clipData: const FlClipData.all(),
        backgroundColor: Colors.white,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  'X: ${spot.x.toStringAsFixed(2)}\nY: ${spot.y.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
            tooltipPadding: const EdgeInsets.all(8),
            tooltipRoundedRadius: 8,
          ),
        ),
      ),
    ),
  );
}

// Bar Chart
Widget buildBarChart(List<FlSpot> data) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
    child: BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.black12,
            width: 1,
          ),
        ),
        barGroups: data.map((spot) {
          return BarChartGroupData(
            x: spot.x.toInt(),
            barRods: [
              BarChartRodData(toY: spot.y, color: Colors.blue),
            ],
          );
        }).toList(),
        minY: 0,
        maxY: data.isNotEmpty
            ? data.map((e) => e.y).reduce((a, b) => a > b ? a : b)
            : 5,
      ),
    ),
  );
}

// Pie Chart
Widget buildPieChart(List<double> data) {
  return PieChart(
    PieChartData(
      sections: data.map((value) {
        return PieChartSectionData(
          value: value,
          color:
              Colors.primaries[data.indexOf(value) % Colors.primaries.length],
          radius: 50,
          title: '${value.toStringAsFixed(1)}%',
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
    ),
  );
}

// Scatter Chart
Widget buildScatterChart(List<FlSpot> data) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
    child: ScatterChart(
      ScatterChartData(
        scatterSpots: data.map((spot) => ScatterSpot(spot.x, spot.y)).toList(),
        minX: 0,
        maxX: data.isNotEmpty ? data.last.x : 5,
        minY: 0,
        maxY: data.isNotEmpty
            ? data.map((e) => e.y).reduce((a, b) => a > b ? a : b)
            : 5,
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.black12,
            width: 1,
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    ),
  );
}

// Area Chart
Widget buildAreaChart(List<FlSpot> data) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
    child: LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.black12,
            width: 1,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: false,
            color: Colors.blue,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData:
                BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
          ),
        ],
        minX: 0,
        maxX: data.isNotEmpty ? data.last.x : 5,
        minY: 0,
        maxY: data.isNotEmpty
            ? data.map((e) => e.y).reduce((a, b) => a > b ? a : b)
            : 5,
        clipData: const FlClipData.all(),
        backgroundColor: Colors.white,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  'X: ${spot.x.toStringAsFixed(2)}\nY: ${spot.y.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
            tooltipPadding: const EdgeInsets.all(8),
            tooltipRoundedRadius: 8,
          ),
        ),
      ),
    ),
  );
}

// Radar Chart
Widget buildRadarChart(List<RadarEntry> data) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
    child: RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            borderColor: Colors.blue,
            borderWidth: 2,
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        radarBorderData: const BorderSide(color: Colors.black12, width: 1),
        gridBorderData: const BorderSide(color: Colors.black12, width: 1),
        titleTextStyle: const TextStyle(fontSize: 12, color: Colors.black87),
        tickCount: 5,
        ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.black87),
      ),
    ),
  );
}
