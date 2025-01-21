import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo_impl.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/components/analysis_parameters_dialog.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/analyse/ui/graph_sensors/components/fl_dot_triangle_painter.dart';

class TimeSeriesChart extends StatefulWidget {
  final SensorDataResponse data;
  final List<String> selectedFields;
  final Function(String field, QueryParams params)? onAnalyze;
  final String? measurementName;
  final String? topic;
  final String windowSize;
  final String deviationThreshold;
  final String timeRange;
  final String windowPeriod;
  final String aggregateFunction;

  const TimeSeriesChart({
    super.key,
    required this.data,
    required this.selectedFields,
    this.onAnalyze,
    this.measurementName,
    this.topic,
    required this.windowSize,
    required this.deviationThreshold,
    required this.timeRange,
    required this.windowPeriod,
    required this.aggregateFunction,
  });

  @override
  State<TimeSeriesChart> createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart> {
  late final Map<String, bool> showTimeView;
  late final Map<String, GlobalKey> chartKeys;
  late List<String> _availableFields;

  @override
  void initState() {
    super.initState();
    _availableFields = _getAvailableFields();
    _initializeMaps();
  }

/*   // get theme from shared preferences
  Future<bool> _isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  } */

  @override
  void didUpdateWidget(TimeSeriesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update available fields if the data has changed
    if (widget.data != oldWidget.data) {
      final newFields = _getAvailableFields();
      // Add any new fields that weren't present before
      for (final field in newFields) {
        if (!_availableFields.contains(field)) {
          showTimeView[field] = true;
          chartKeys[field] = GlobalKey();
        }
      }
      _availableFields = newFields;
    }
  }

  List<String> _getAvailableFields() {
    final result = widget.data.result;
    if (result == null) return [];

    return result.getFieldNames().where((field) {
      final data = result.getField(field);
      return data != null && data.value != null && data.value!.isNotEmpty;
    }).toList();
  }

  void _initializeMaps() {
    showTimeView = {
      if (_availableFields.isNotEmpty) 'combined': true,
      for (var field in _availableFields) field: true,
    };
    chartKeys = {
      if (_availableFields.isNotEmpty) 'combined': GlobalKey(),
      for (var field in _availableFields) field: GlobalKey(),
    };
  }

  Future<void> _saveChartAsPng(String field) async {
    try {
      final boundary = chartKeys[field]!.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();

      // Calculate title height first
      final titleStyle = TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16 * 3, // Scale up for high resolution
        fontWeight: FontWeight.bold,
      );
      final titleSpan = TextSpan(
        text: field == 'combined'
            ? (showTimeView[field]!
                ? 'Combined Sensor Data Over Time'
                : 'Combined Frequency-Magnitude')
            : (showTimeView[field]!
                ? '${_capitalize(field)} Over Time'
                : '${_capitalize(field)} Over Frequency'),
        style: titleStyle,
      );
      final titlePainter = TextPainter(
        text: titleSpan,
        textDirection: TextDirection.ltr,
      );
      titlePainter.layout(maxWidth: imageWidth);

      // Create a larger canvas to accommodate title
      final totalHeight =
          imageHeight + titlePainter.height + 32; // 32 for padding
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
 /*      final paint = Paint()..color = Colors.white; */

      // Draw white background for entire image
      canvas.drawRect(
        Rect.fromLTWH(0, 0, imageWidth, totalHeight),
        Paint()..color = Theme.of(context).colorScheme.surface,
      );

      // Draw title
      titlePainter.paint(canvas, const Offset(24, 24));

      // Draw the chart image below the title
      final imageShader =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (imageShader != null) {
        final chartImage =
            await decodeImageFromList(imageShader.buffer.asUint8List());
        canvas.drawImage(
            chartImage, Offset(0, titlePainter.height + 32), Paint());
      }

      // Create the final image with the new height
      final picture = recorder.endRecording();
      final finalImage =
          await picture.toImage(image.width, totalHeight.toInt());
      final byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
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
        IconButton(
          icon: const Icon(
            Icons.save_alt,
          ),
          onPressed: () => _saveChartAsPng(field),
          tooltip: 'Save as PNG',
        ),
        if (widget.onAnalyze != null && field != 'combined')
          IconButton(
            icon: const Icon(
              Icons.analytics_outlined,
            ),
            onPressed: () => _showAnalysisDialog(field),
            tooltip: 'Analyze Sensor',
          ),
      ],
    );
  }

  void _showAnalysisDialog(String field) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AnalysisParametersDialog(
        initialWindowPeriod: widget.windowSize,
        initialDeviation: widget.deviationThreshold,
      ),
    );

    if (result != null && context.mounted && widget.onAnalyze != null) {
      final params = QueryParams(
        measurementName: widget.measurementName,
        topic: widget.topic,
        fields: field,
        sensorsToAnalyze: field,
        windowSize: result['windowSize'],
        deviationThreshold: result['deviation'],
        bucket: 'CloudHub',
        org: 'DIC',
        timeRangeStart: widget.timeRange,
        windowPeriod: widget.windowPeriod,
        aggregateFunc: widget.aggregateFunction,
      );
      widget.onAnalyze!(field, params);
    }
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

    // Check if ticket exists for this field
    final hasTicket = widget.data.ticket?[field] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildSectionTitle(title)),
                  if (hasTicket)
                    IconButton(
                      icon: const Icon(Icons.warning_amber_rounded,
                          color: Colors.red),
                      onPressed: () => _showTicketDetails(context, field),
                      tooltip: 'Show Ticket Details',
                    ),
                ],
              ),
            ),
            _buildToggleButton(field),
          ],
        ),
        RepaintBoundary(
          key: chartKeys[field],
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLineChart(
                  field == 'combined'
                      ? (isTimeView
                          ? _createCombinedOverTimeData()
                          : _createCombinedFreqMagnitudeData())
                      : _createLineBarsData(field: field, byTime: isTimeView),
                  isTimeXAxis: isTimeView,
                  isMicroUnits: !isTimeView,
                  field: field,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTicketDetails(BuildContext context, String field) {
    final ticket = widget.data.ticket?[field];
    if (ticket == null) return;

    final createdAt = DateTime.parse(ticket['created_at'].toString());
    final formattedDate =
        '${createdAt.day}/${createdAt.month}/${createdAt.year}, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')} ${createdAt.hour >= 12 ? 'PM' : 'AM'}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Ticket Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: 'Name: ',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                children: [
                  TextSpan(
                    text: ticket['name'].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Description: ',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                children: [
                  TextSpan(
                    text: ticket['description'].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Created At: ',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                children: [
                  TextSpan(
                    text: formattedDate,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.result == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_availableFields.length > 1)
            RepaintBoundary(
              key: const ValueKey('graph_section_combined'),
              child: _buildGraphSection('combined'),
            ),
          for (var field in _availableFields)
            if (_hasDataForField(field))
              RepaintBoundary(
                key: ValueKey('graph_section_$field'),
                child: _buildGraphSection(field),
              ),
        ],
      ),
    );
  }

  bool _hasDataForField(String field) {
    final result = widget.data.result;
    if (result == null) return false;

    final dataForField = result.getField(field);
    if (dataForField == null ||
        dataForField.value == null ||
        dataForField.value!.isEmpty) {
      return false;
    }

    final allZero = dataForField.value!.every((v) => v == 0.0);
    if (allZero) {
      return false;
    }

    return true;
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

  String _formatTimeAxisLabel(double value, bool scaleByDay) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (scaleByDay) {
      return '${date.day}/${date.month}';
    } else {
      final hh = date.hour.toString().padLeft(2, '0');
      final mm = date.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
  }

  Widget _buildLineChart(
    List<LineChartBarData> lineBarsData, {
    required bool isTimeXAxis,
    required bool isMicroUnits,
    required String field,
  }) {
    if (lineBarsData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Add dominant frequency points before scaling
    final dominantFreqPoints = !isTimeXAxis
        ? _buildDominantFreqPoints(
            field: field,
            isMicroUnits: isMicroUnits,
          )
        : <LineChartBarData>[];

    // Scale all data points including dominant frequencies
    final yScaleFactor = isMicroUnits ? 1e6 : 1.0;
    final scaledLineBarsData = _scaleLineBarsData(lineBarsData, yScaleFactor);
    final scaledDominantPoints =
        _scaleLineBarsData(dominantFreqPoints, yScaleFactor);

    final List<LineChartBarData> allBarsData = [
      ...scaledLineBarsData,
      ...scaledDominantPoints
    ];

    // Calculate limits using all data points
    var (minX, maxX, minY, maxY) =
        _calculateAxisLimits(allBarsData, isTimeXAxis);

    if (!isTimeXAxis) {
      minY = 0;
    }

    if (minX == null || maxX == null || minY == null || maxY == null) {
      return const Center(child: Text('No valid data to display'));
    }

    if (minX == maxX) {
      minX -= 1;
      maxX += 1;
    }
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final xInterval = (maxX - minX) / 4;
    final yInterval = (maxY - minY) / 4;

    // Determine if we should scale by day based on time range
    final scaleByDay =
        isTimeXAxis && (maxX - minX) > Duration.millisecondsPerDay;

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
        child: LineChart(
          LineChartData(
            lineBarsData: allBarsData,
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: true,
              horizontalInterval: yInterval,
              verticalInterval: xInterval,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1),
                strokeWidth: 0.5,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1),
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
                      return Transform.rotate(
                        angle: -45 * pi / 180,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _formatTimeAxisLabel(value, scaleByDay),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Transform.rotate(
                        angle: -45 * pi / 180,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _formatFrequency(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
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
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        _formatYAxisLabel(value),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            clipData: const FlClipData.all(),
            backgroundColor:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                tooltipRoundedRadius: 8,
                tooltipMargin: 8,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((spot) {
                    final barData = spot.bar;
                    final xValue = isTimeXAxis
                        ? DateTime.fromMillisecondsSinceEpoch(spot.x.toInt())
                            .toString()
                        : _formatFrequency(spot.x);
                    final yValue = spot.y.toStringAsFixed(2);

                    final isDominantFreq = !isTimeXAxis &&
                        barData.dotData.show &&
                        barData.dotData.getDotPainter(spot, 0, barData, 0)
                            is FlDotTrianglePainter;

                    return LineTooltipItem(
                      isDominantFreq
                          ? 'Dominant Frequency\n'
                              'Frequency: $xValue\n'
                              'Magnitude: $yValue'
                          : 'Value: $yValue\n'
                              'Time: $xValue',
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildDominantFreqPoints({
    required String field,
    required bool isMicroUnits,
  }) {
    final dominantFreqPoints = <LineChartBarData>[];

    if (widget.data.dominate_frequencies != null &&
        widget.data.magnitude != null &&
        widget.data.frequency != null) {
      final freqList = widget.data.dominate_frequencies![field] ?? [];
      final magData = widget.data.magnitude![field] ?? [];
      final freqData = widget.data.frequency![field] ?? [];

      for (final freq in freqList) {
        final index = freqData.indexOf(freq);
        if (index != -1 && index < magData.length) {
          dominantFreqPoints.add(
            LineChartBarData(
              spots: [FlSpot(freq, magData[index])],
              isCurved: false,
              color: Colors.red,
              barWidth: 0,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    const FlDotTrianglePainter(
                  size: 12,
                  color: Colors.red,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(show: false),
            ),
          );
        }
      }
    }

    return dominantFreqPoints;
  }

  List<LineChartBarData> _scaleLineBarsData(
      List<LineChartBarData> lineBarsData, double yScaleFactor) {
    return lineBarsData.map((barData) {
      final scaledSpots = barData.spots
          .map((spot) => FlSpot(spot.x, spot.y * yScaleFactor))
          .toList();
      return LineChartBarData(
        spots: scaledSpots,
        isCurved: barData.isCurved,
        color: barData.color,
        barWidth: barData.barWidth,
        isStrokeCapRound: barData.isStrokeCapRound,
        dotData: barData.dotData,
        belowBarData: barData.belowBarData,
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

    final colorScheme = Theme.of(context).colorScheme;
    final color = _getColorForField(field);
    final (xValues, yValues) = _extractData(result, field, byTime);

    if (xValues.isEmpty || yValues.isEmpty) return [];

    final List<LineChartBarData> chartData = [];

    // Determine if we should show points based on data density
    final showPoints = xValues.length <= 100;
    final pointSize = xValues.length <= 50 ? 4.0 : 3.0;

    // Add main line data
    final spots = List<FlSpot>.generate(
      min(xValues.length, yValues.length),
      (i) => FlSpot(xValues[i], yValues[i]),
    );

    chartData.add(
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: showPoints,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: pointSize,
            color: color.withValues(alpha: 0.7),
            strokeWidth: 1,
            strokeColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        belowBarData: BarAreaData(show: false),
      ),
    );

    // Add anomaly regions in time mode
    if (byTime && widget.data.anomaly_regions?[field] != null) {
      final anomalyRegions = widget.data.anomaly_regions![field]!;
      final data = result.getField(field);
      final times = data?.time;
      final values = data?.value;

      if (times != null && values != null) {
        for (final region in anomalyRegions) {
          if (region.length >= 2) {
            final startIndex = region[0].toInt();
            final endIndex = region[1].toInt();

            // Create spots for the anomaly region
            final anomalySpots = <FlSpot>[];
            for (var i = startIndex;
                i <= endIndex && i < times.length && i < values.length;
                i++) {
              final timeValue = DateTime.parse(times[i].toString())
                  .millisecondsSinceEpoch
                  .toDouble();
              anomalySpots.add(FlSpot(timeValue, values[i]));
            }

            if (anomalySpots.isNotEmpty) {
              // Get min and max Y values to create full-height shading
              double minY = double.infinity;
              double maxY = double.negativeInfinity;
              for (final value in values) {
                if (value < minY) minY = value;
                if (value > maxY) maxY = value;
              }

              // Create spots for the full height rectangle
              final startTime = DateTime.parse(times[startIndex].toString())
                  .millisecondsSinceEpoch
                  .toDouble();
              final endTime = DateTime.parse(times[endIndex].toString())
                  .millisecondsSinceEpoch
                  .toDouble();

              // Add shaded area for anomaly region (full height)
              chartData.add(
                LineChartBarData(
                  spots: [
                    FlSpot(startTime, minY - (maxY - minY) * 0.1),
                    FlSpot(startTime, maxY + (maxY - minY) * 0.1),
                    FlSpot(endTime, maxY + (maxY - minY) * 0.1),
                    FlSpot(endTime, minY - (maxY - minY) * 0.1),
                    FlSpot(startTime, minY - (maxY - minY) * 0.1),
                  ],
                  isCurved: false,
                  color: colorScheme.error.withValues(alpha: 0.1),
                  barWidth: 0,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.error.withValues(alpha: 0.1),
                  ),
                ),
              );

              // Add the actual data line for the anomaly region
              chartData.add(
                LineChartBarData(
                  spots: anomalySpots,
                  isCurved: false,
                  color: colorScheme.error.withValues(alpha: 0.5),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: pointSize + 1,
                      color: colorScheme.error.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      strokeColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              );
            }
          }
        }
      }
    }

    return chartData;
  }

  (List<double>, List<double>) _extractData(
      Result? result, String field, bool byTime) {
    List<double>? yValues;
    List<double>? xValues;

    if (result == null) return ([], []);

    if (byTime) {
      final data = _getDataForField(field);
      if (data != null && data.time != null && data.value != null) {
        yValues = data.value;

        // Convert times to milliseconds
        final times = data.time!
            .map((t) =>
                DateTime.parse(t.toString()).millisecondsSinceEpoch.toDouble())
            .toList();

        // If data spans more than a day, consider sampling
        if (times.length > 1000) {
          // If we have too many points
          final timeRange = times.last - times.first;
          if (timeRange > Duration.millisecondsPerDay) {
            // Sample data to reduce points while maintaining pattern
            final sampledIndices =
                _sampleDataPoints(times.length, 1000); // Limit to 1000 points
            xValues = sampledIndices.map((i) => times[i]).toList();
            yValues = sampledIndices.map((i) => data.value![i]).toList();
          } else {
            xValues = times;
          }
        } else {
          xValues = times;
        }
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

  List<int> _sampleDataPoints(int totalPoints, int targetPoints) {
    if (totalPoints <= targetPoints) {
      return List.generate(totalPoints, (i) => i);
    }

    final step = totalPoints / targetPoints;
    final indices = <int>[];
    var currentIndex = 0.0;

    while (currentIndex < totalPoints) {
      indices.add(currentIndex.round());
      currentIndex += step;
    }

    // Always include the last point
    if (!indices.contains(totalPoints - 1)) {
      indices.add(totalPoints - 1);
    }

    return indices;
  }

  Data? _getDataForField(String field) {
    final result = widget.data.result;
    if (result == null) return null;
    return result.getField(field);
  }

  Color _getColorForField(String field) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (field) {
      case 'accelX':
        return colorScheme.primary;
      case 'accelY':
        return colorScheme.secondary;
      case 'accelZ':
        return colorScheme.tertiary;
      case 'humidity':
        return colorScheme.error;
      case 'temperature':
        return colorScheme.inversePrimary;
      default:
        return colorScheme.outline;
    }
  }
}
