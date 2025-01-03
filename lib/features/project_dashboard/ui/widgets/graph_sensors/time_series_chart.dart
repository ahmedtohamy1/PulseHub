import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class TimeSeriesChart extends StatefulWidget {
  final SensorDataResponse data;
  final List<String> selectedFields;

  const TimeSeriesChart({
    super.key,
    required this.data,
    required this.selectedFields,
  });

  @override
  State<TimeSeriesChart> createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart> {
  late final Map<String, bool> showTimeView;
  late final Map<String, GlobalKey> chartKeys;

  @override
  void initState() {
    super.initState();
    _initializeMaps();
  }

  List<String> _getAvailableFields() {
    final result = widget.data.result;
    if (result == null) return [];

    return [
      if (result.accelX?.value != null) 'accelX',
      if (result.accelY?.value != null) 'accelY',
      if (result.accelZ?.value != null) 'accelZ',
      if (result.humidity?.value != null) 'humidity',
      if (result.temperature?.value != null) 'temperature',
    ];
  }

  void _initializeMaps() {
    final availableFields = _getAvailableFields();
    showTimeView = {
      if (availableFields.isNotEmpty) 'combined': true,
      for (var field in availableFields) field: true,
    };
    chartKeys = {
      if (availableFields.isNotEmpty) 'combined': GlobalKey(),
      for (var field in availableFields) field: GlobalKey(),
    };
  }

  Future<void> _saveChartAsPng(String field) async {
    try {
      final boundary = chartKeys[field]!.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName =
          'pulsehub_${field}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.png';
      final tempFile = File('${tempDir.path}\\$fileName');
      await tempFile.writeAsBytes(pngBytes);

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final position = box!.localToGlobal(Offset.zero);
        final size = box.size;

        await Share.shareXFiles(
          [XFile(tempFile.path)],
          subject: 'PulseHub Chart',
          sharePositionOrigin: Rect.fromLTWH(
            position.dx,
            position.dy,
            size.width,
            size.height / 2,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share chart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildToggleButton(String field) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: true,
              label: Text('T'),
              icon: Icon(Icons.timer_outlined, size: 16),
            ),
            ButtonSegment<bool>(
              value: false,
              label: Text('F'),
              icon: Icon(Icons.show_chart, size: 16),
            ),
          ],
          selected: {showTimeView[field]!},
          onSelectionChanged: (Set<bool> newSelection) {
            setState(() {
              showTimeView[field] = newSelection.first;
            });
          },
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.save_alt, size: 16),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _saveChartAsPng(field),
          tooltip: 'Save as PNG',
        ),
      ],
    );
  }

  Widget _buildGraphSection(String field) {
    final isTimeView = showTimeView[field]!;
    final title = field == 'combined'
        ? (isTimeView
            ? 'Combined Sensor Data Over Time'
            : 'Combined Frequency-Magnitude')
        : (isTimeView
            ? '${_capitalize(field)} Over Time'
            : '${_capitalize(field)} Over Frequency');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSectionTitle(title),
            ),
            _buildToggleButton(field),
          ],
        ),
        RepaintBoundary(
          key: chartKeys[field],
          child: _buildLineChart(
            field == 'combined'
                ? (isTimeView
                    ? _createCombinedOverTimeData()
                    : _createCombinedFreqMagnitudeData())
                : _createLineBarsData(field: field, byTime: isTimeView),
            isTimeXAxis: isTimeView,
            isMicroUnits: !isTimeView,
            field: field,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.result == null) {
      return const Center(child: Text('No data available'));
    }

    final availableFields = _getAvailableFields();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Combined sensor data
          if (availableFields.length > 1) _buildGraphSection('combined'),
          // Individual sensor data
          for (var field in availableFields)
            if (_hasDataForField(field)) _buildGraphSection(field),
        ],
      ),
    );
  }

  bool _hasDataForField(String field) {
    final result = widget.data.result;
    if (result == null) return false;

    final dataForField = _getDataForField(field);
    if (dataForField == null ||
        dataForField.value == null ||
        dataForField.value!.isEmpty) {
      return false;
    }

    // Optionally, skip if *all* values are zero (or NaN):
    final allZero = dataForField.value!.every((v) => v == 0.0);
    if (allZero) {
      return false; // or keep true if you want to see a "flat line" at zero
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

  String _formatYAxisLabel(double value) {
    if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else if (value.abs() < 0.01) {
      return value.toStringAsExponential(1);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  String _formatFrequency(double value) {
    if (value == 0) return '0e0';
    final exp = (log(value.abs()) / ln10).floor();
    final mantissa = (value / pow(10, exp)).floor();
    return '${mantissa}e$exp';
  }

  /// Creates the main line chart widget.
  /// Draws extra vertical lines for each dominant frequency when not in time mode.
  Widget _buildLineChart(
    List<LineChartBarData> lineBarsData, {
    required bool isTimeXAxis,
    required bool isMicroUnits,
    required String field,
  }) {
    // Early exit if there's no data to show
    if (lineBarsData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Scale the Y-values if needed (e.g., convert raw acceleration to micro units)
    final yScaleFactor = isMicroUnits ? 1e6 : 1.0;
    lineBarsData = _scaleLineBarsData(lineBarsData, yScaleFactor);

    // Calculate axis limits (min/max X/Y)
    var (minX, maxX, minY, maxY) =
        _calculateAxisLimits(lineBarsData, isTimeXAxis);

    // Force minY=0 for frequency-based charts
    if (!isTimeXAxis) {
      minY = 0;
    }

    // If we failed to calculate valid axis limits, return a fallback
    if (minX == null || maxX == null || minY == null || maxY == null) {
      return const Center(child: Text('No valid data to display'));
    }

    // If the data is flat (single point), expand axes slightly
    if (minX == maxX) {
      minX -= 1;
      maxX += 1;
    }
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    // Calculate intervals for grid lines
    double xInterval = (maxX - minX) / 4;
    double yInterval = (maxY - minY) / 4;
    if (xInterval <= 0) xInterval = 1;
    if (yInterval <= 0) yInterval = 1;

    // Build the list of vertical lines for dominant frequencies
    final verticalLines =
        _buildDominantFreqLines(isTimeXAxis: isTimeXAxis, field: field);

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
        child: LineChart(
          LineChartData(
            lineBarsData: lineBarsData,
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,

            // Show background grid lines
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

            // Axis titles and labels
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: xInterval,
                  getTitlesWidget: (value, meta) {
                    if (isTimeXAxis) {
                      // Convert X-value (ms since epoch) to HH:MM
                      final date =
                          DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      final hh = date.hour.toString().padLeft(2, '0');
                      final mm = date.minute.toString().padLeft(2, '0');
                      return Transform.rotate(
                        angle: -45 * pi / 180,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('$hh:$mm',
                              style: const TextStyle(fontSize: 10)),
                        ),
                      );
                    } else {
                      // Frequency axis label (e.g., 1e2, 2e3, etc.)
                      return Transform.rotate(
                        angle: -45 * pi / 180,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(_formatFrequency(value),
                              style: const TextStyle(fontSize: 10)),
                        ),
                      );
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    // Format Y-values with k suffix or scientific notation
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        _formatYAxisLabel(value),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.right,
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

            // Draw a border around the chart
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.black12,
                width: 1,
              ),
            ),

            // Here is where we set the extra lines (vertical lines for freq)
            extraLinesData: ExtraLinesData(
              horizontalLines: [],
              verticalLines: verticalLines,
            ),

            // Clip the chart so drawing doesn’t overflow the border
            clipData: const FlClipData.all(),

            // White background
            backgroundColor: Colors.white,

            // Enable touches and tooltips
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((spot) {
                    final xValue = isTimeXAxis
                        ? DateTime.fromMillisecondsSinceEpoch(spot.x.toInt())
                            .toString()
                        : _formatFrequency(spot.x);
                    final yValue = spot.y.toStringAsFixed(2);
                    return LineTooltipItem(
                      // Example tooltip text: "accelX\nX: 2023-06-04 12:30:00\nY: 12.34"
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

  /// Builds a list of [VerticalLine] objects for each of the field's dominant frequencies.
  ///
  /// Only applies if we're NOT in time mode (`!isTimeXAxis`).
  List<VerticalLine> _buildDominantFreqLines({
    required bool isTimeXAxis,
    required String field,
  }) {
    final verticalLines = <VerticalLine>[];

    // Only draw vertical lines for frequency-based chart
    if (!isTimeXAxis && widget.data.dominate_frequencies != null) {
      final freqList = widget.data.dominate_frequencies![field] ?? [];
      for (final freq in freqList) {
        verticalLines.add(
          VerticalLine(
            x: freq,
            color: Colors.red,
            
            strokeWidth: 1,
            dashArray: [5, 5], // dotted line style
          ),
        );
      }
    }

    return verticalLines;
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

  List<LineChartBarData> _createCombinedOverTimeData() {
    return _getAvailableFields()
        .map((f) => _createLineBarsData(field: f, byTime: true))
        .expand((list) => list)
        .toList()
        .take(6)
        .toList();
  }

  List<LineChartBarData> _createCombinedFreqMagnitudeData() {
    return _getAvailableFields()
        .map((f) => _createLineBarsData(field: f, byTime: false))
        .expand((list) => list)
        .toList()
        .take(6)
        .toList();
  }

  List<LineChartBarData> _createLineBarsData({
    required String field,
    required bool byTime,
  }) {
    final result = widget.data.result;
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
      final data = _getDataForField(field);
      if (data != null) {
        yValues = data.value;
        xValues =
            data.time?.map((t) => t.millisecondsSinceEpoch.toDouble()).toList();
      }
    } else {
      final freqData = widget.data.frequency?[field];
      final magData = widget.data.magnitude?[field];

      if (freqData != null && magData != null) {
        xValues = freqData;
        yValues = magData;
      }
    }

    return (xValues ?? [], yValues ?? []);
  }

  Data? _getDataForField(String field) {
    final result = widget.data.result;
    if (result == null) return null;

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

  Widget _buildTriangleMarker(double size, Color color) {
    return CustomPaint(
      size: Size(size, size),
      painter: TrianglePainter(color: color),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
