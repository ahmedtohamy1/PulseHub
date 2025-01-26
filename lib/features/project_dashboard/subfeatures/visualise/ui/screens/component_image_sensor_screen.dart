import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/cubit/visualise_cubit.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/widgets/sensor_selection_dialog.dart';

class ComponentImageSensorScreen extends StatefulWidget {
  final int projectId;
  final int dashboardId;
  final int componentId;
  final String imageUrl;
  final String imageName;
  final Map<String, List<double>> existingSensors;

  const ComponentImageSensorScreen({
    super.key,
    required this.projectId,
    required this.dashboardId,
    required this.componentId,
    required this.imageUrl,
    required this.imageName,
    required this.existingSensors,
  });

  @override
  State<ComponentImageSensorScreen> createState() =>
      _ComponentImageSensorScreenState();
}

class _ComponentImageSensorScreenState
    extends State<ComponentImageSensorScreen> {
  late PhotoViewController _photoViewController;
  final ValueNotifier<int> _repaintNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isListExpanded = ValueNotifier(false);
  final List<Sensor> _placedSensors = [];
  ui.Size? _imageSize;
  late final VisualiseCubit _visualiseCubit;

  @override
  void initState() {
    super.initState();
    print('Initializing ComponentImageSensorScreen');
    print('Existing sensors: ${widget.existingSensors}');

    _photoViewController = PhotoViewController()
      ..outputStateStream.listen((state) {
        _repaintNotifier.value++;
      });

    // Load monitoring data first
    _loadMonitoringData();

    // Load image to get its size
    _loadImage();
  }

  Future<void> _loadMonitoringData() async {
    final projectDashboardCubit = context.read<ProjectDashboardCubit>();
    await projectDashboardCubit.getMonitoring(widget.projectId);

    // Now that we have monitoring data, initialize sensors
    final monitoringState = projectDashboardCubit.state;
    print('Monitoring state after loading: $monitoringState');

    if (monitoringState is ProjectDashboardMonitoringSuccess) {
      // Convert existing sensors map to list of Sensor objects
      for (final entry in widget.existingSensors.entries) {
        final sensorId = entry.key;
        final coordinates = entry.value; // This is List<double> with [x, y]
        print('Processing sensor $sensorId with coordinates $coordinates');

        // Find the sensor in monitoring state
        Sensor? sensor;
        outer:
        for (final monitoring
            in monitoringState.monitoringResponse.monitorings ?? []) {
          for (final usedSensor in monitoring.usedSensors ?? []) {
            for (final s in usedSensor.sensors ?? []) {
              if (s.sensorId.toString() == sensorId) {
                sensor = s;
                print('Found matching sensor: ${sensor?.name ?? 'unnamed'}');
                break outer;
              }
            }
          }
        }

        if (sensor != null) {
          // Create updated sensor with coordinates
          final updatedSensor = _createUpdatedSensor(
            sensor,
            coordinates[0], // x coordinate
            coordinates[1], // y coordinate
          );
          setState(() {
            _placedSensors.add(updatedSensor);
          });
          print(
              'Added sensor to _placedSensors. Total count: ${_placedSensors.length}');
        }
      }
    }
  }

  void _loadImage() {
    final imageProvider = NetworkImage(widget.imageUrl);
    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        setState(() {
          _imageSize = ui.Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      }),
    );
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _repaintNotifier.dispose();
    _isListExpanded.dispose();
    super.dispose();
  }

  void _handleSave() {
    // Print component info
    print('Component ID: ${widget.componentId}');
    print('Image Name: ${widget.imageName}');
    print('Image URL: ${widget.imageUrl}');

    // Convert placed sensors to required format
    final sensorsIdsAndCoordinates = <String, List<double>>{};
    for (final sensor in _placedSensors) {
      sensorsIdsAndCoordinates[sensor.sensorId.toString()] = [
        sensor.coordinateX ?? 0.0,
        sensor.coordinateY ?? 0.0,
      ];
    }

    print('Sensors Info:');
    for (final sensor in _placedSensors) {
      print('- Sensor ID: ${sensor.sensorId}');
      print('  Name: ${sensor.name}');
      print('  Type: ${sensor.typeId}');
      print('  Coordinates: (${sensor.coordinateX}, ${sensor.coordinateY})');
    }

    print('Formatted Sensors Data: $sensorsIdsAndCoordinates');
  }

  void _onImageTap(
      TapUpDetails details, PhotoViewControllerValue controllerValue) async {
    if (_imageSize == null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final viewportSize = renderBox.size;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // Get current scale and position from controller
    final scale = controllerValue.scale ?? 1.0;
    final position = controllerValue.position;

    // Calculate the center of the viewport
    final viewportCenter = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );

    // Calculate the position relative to the center of the viewport
    final relativePosition = localPosition - viewportCenter;

    // Adjust for the current position offset and scale
    final adjustedX = (relativePosition.dx - position.dx) / scale;
    final adjustedY = (relativePosition.dy - position.dy) / scale;

    // Convert to image coordinates (0,0 is bottom-left corner)
    final imageX = adjustedX + (_imageSize!.width / 2);
    final imageY = _imageSize!.height - (adjustedY + (_imageSize!.height / 2));

    // Validate coordinates
    if (imageX < 0 ||
        imageX > _imageSize!.width ||
        imageY < 0 ||
        imageY > _imageSize!.height) {
      return;
    }

    // Check if too close to existing sensors
    if (_isTooCloseToExistingSensor(imageX, imageY)) {
      _showTooCloseWarning();
      return;
    }

    final selectedSensorId = await _showSensorSelectionDialog();
    if (selectedSensorId == null) return;

    // Get the selected sensor from the monitoring state
    final monitoringState = context.read<ProjectDashboardCubit>().state;
    if (monitoringState is! ProjectDashboardMonitoringSuccess) return;

    Sensor? selectedSensor;
    outer:
    for (final monitoring
        in monitoringState.monitoringResponse.monitorings ?? []) {
      for (final usedSensor in monitoring.usedSensors ?? []) {
        for (final sensor in usedSensor.sensors ?? []) {
          if (sensor.sensorId.toString() == selectedSensorId) {
            selectedSensor = sensor;
            break outer;
          }
        }
      }
    }

    if (selectedSensor == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Selected sensor not found'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    // Create a copy of the sensor with updated coordinates
    final updatedSensor = _createUpdatedSensor(selectedSensor, imageX, imageY);

    setState(() {
      _placedSensors.add(updatedSensor);
    });
  }

  bool _isTooCloseToExistingSensor(double x, double y,
      {double minDistance = 5}) {
    for (final sensor in _placedSensors) {
      final distance = _calculateDistance(
          x,
          y,
          sensor.coordinateX?.toDouble() ?? 0,
          sensor.coordinateY?.toDouble() ?? 0);
      if (distance < minDistance) {
        return true;
      }
    }
    return false;
  }

  double _calculateDistance(double x1, double y1, double x2, double y2) {
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
  }

  void _showTooCloseWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Cannot place sensor at the same point as another sensor'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<String?> _showSensorSelectionDialog() {
    final placedSensorIds =
        _placedSensors.map((s) => s.sensorId.toString()).toList();
    final cubit = context.read<ProjectDashboardCubit>();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: SensorSelectionDialog(
          projectId: widget.projectId,
          placedSensorIds: placedSensorIds,
        ),
      ),
    );
  }

  // Create a new sensor with updated coordinates
  Sensor _createUpdatedSensor(Sensor sensor, double x, double y) {
    return Sensor(
      sensorId: sensor.sensorId,
      name: sensor.name,
      uuid: sensor.uuid,
      usedSensor: sensor.usedSensor,
      cloudHub: sensor.cloudHub,
      installDate: sensor.installDate,
      typeId: sensor.typeId,
      dataSource: sensor.dataSource,
      readingsPerDay: sensor.readingsPerDay,
      active: sensor.active,
      coordinateX: x,
      coordinateY: y,
      coordinateZ: sensor.coordinateZ,
      longitude: sensor.longitude,
      latitude: sensor.latitude,
      calibrated: sensor.calibrated,
      calibrationDate: sensor.calibrationDate,
      calibrationComments: sensor.calibrationComments,
      event: sensor.event,
      eventLastStatus: sensor.eventLastStatus,
      status: sensor.status,
      cloudHubTime: sensor.cloudHubTime,
      sendTime: sensor.sendTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Sensor Placement',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isListExpanded,
            builder: (context, isExpanded, _) {
              return IconButton(
                onPressed: () => _isListExpanded.value = !isExpanded,
                icon: Badge(
                  label: Text(_placedSensors.length.toString()),
                  child: Icon(
                    isExpanded ? Icons.sensors_off : Icons.sensors,
                  ),
                ),
              );
            },
          ),
          IconButton(
            onPressed: _handleSave,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(widget.imageUrl),
            controller: _photoViewController,
            basePosition: Alignment.center,
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            onTapUp: (context, details, controllerValue) =>
                _onImageTap(details, controllerValue),
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          if (_placedSensors.isNotEmpty)
            Positioned.fill(
              child: ValueListenableBuilder<int>(
                valueListenable: _repaintNotifier,
                builder: (context, _, __) {
                  return IgnorePointer(
                    child: CustomPaint(
                      painter: SensorOverlayPainter(
                        sensors: _placedSensors,
                        imageSize: _imageSize,
                        scale: _photoViewController.scale,
                        position: _photoViewController.position,
                      ),
                    ),
                  );
                },
              ),
            ),
          ValueListenableBuilder<bool>(
            valueListenable: _isListExpanded,
            builder: (context, isExpanded, _) {
              if (!isExpanded) return const SizedBox.shrink();
              return _PlacedSensorsList(
                placedSensors: _placedSensors,
                onRemove: (index) =>
                    setState(() => _placedSensors.removeAt(index)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SensorOverlayPainter extends CustomPainter {
  final List<Sensor> sensors;
  final ui.Size? imageSize;
  final double? scale;
  final Offset? position;

  SensorOverlayPainter({
    required this.sensors,
    required this.imageSize,
    required this.scale,
    required this.position,
  });

  Color _sensorColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize == null || scale == null || position == null) return;

    for (final sensor in sensors) {
      if (sensor.coordinateX == null || sensor.coordinateY == null) continue;

      // Convert image coordinates to screen coordinates
      final screenX =
          ((sensor.coordinateX! - (imageSize!.width / 2)) * scale!) +
              size.width / 2 +
              position!.dx;
      final screenY =
          ((imageSize!.height - sensor.coordinateY! - (imageSize!.height / 2)) *
                  scale!) +
              size.height / 2 +
              position!.dy;

      // Draw sensor background circle
      final bgPaint = Paint()
        ..color = _sensorColor(sensor.status).withOpacity(0.2)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = _sensorColor(sensor.status)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (scale ?? 1.0);

      final circleRadius = 10.0 * (scale ?? 1.0);

      // Draw background circle
      canvas.drawCircle(
        Offset(screenX, screenY),
        circleRadius,
        bgPaint,
      );

      // Draw border circle
      canvas.drawCircle(
        Offset(screenX, screenY),
        circleRadius,
        borderPaint,
      );

      // Draw sensor name/ID
      final textSpan = TextSpan(
        text: sensor.name ?? sensor.sensorId.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12 * (scale ?? 1.0),
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Draw text background
      final textBackgroundRect = Rect.fromLTWH(
        screenX + circleRadius + 4,
        screenY - textPainter.height / 2,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(textBackgroundRect, const Radius.circular(4)),
        Paint()..color = Colors.black.withOpacity(0.7),
      );

      // Draw text
      textPainter.paint(
        canvas,
        Offset(
          screenX + circleRadius + 8,
          screenY - textPainter.height / 2 + 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SensorOverlayPainter oldDelegate) {
    return oldDelegate.sensors != sensors ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.scale != scale ||
        oldDelegate.position != position;
  }
}

class _PlacedSensorsList extends StatelessWidget {
  final List<Sensor> placedSensors;
  final Function(int) onRemove;

  const _PlacedSensorsList({
    required this.placedSensors,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      right: 16,
      top: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Placed Sensors (${placedSensors.length})',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                  maxWidth: 300,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: placedSensors.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final sensor = placedSensors[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _sensorColor(sensor.status).withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _sensorColor(sensor.status),
                            width: 2,
                          ),
                        ),
                      ),
                      title: Text(
                        '${sensor.name} (${sensor.coordinateX?.toStringAsFixed(1) ?? '0'}, '
                        '${sensor.coordinateY?.toStringAsFixed(1) ?? '0'})',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(sensor.typeId ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => onRemove(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _sensorColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
