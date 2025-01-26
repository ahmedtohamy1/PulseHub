import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/ui/widgets/sensor_selection_dialog.dart';

class ImageSensorPlacingScreen extends StatefulWidget {
  final int projectId;

  const ImageSensorPlacingScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ImageSensorPlacingScreen> createState() =>
      _ImageSensorPlacingScreenState();
}

class _ImageSensorPlacingScreenState extends State<ImageSensorPlacingScreen> {
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  final List<Sensor> _sensors = [];
  final List<Sensor> _placedSensors = [];
  final _photoViewController = PhotoViewController();
  ui.Size? _imageSize;
  final _repaintNotifier = ValueNotifier<int>(0);
  final _isListExpanded = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _photoViewController.outputStateStream.listen((_) {
      _repaintNotifier.value++;
    });
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _repaintNotifier.dispose();
    _isListExpanded.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        final imageFile = File(image.path);
        final decodedImage =
            await decodeImageFromList(await imageFile.readAsBytes());
        setState(() {
          _selectedImage = image;
          _imageSize = ui.Size(
            decodedImage.width.toDouble(),
            decodedImage.height.toDouble(),
          );
          _placedSensors.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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

  void _onImageTap(
      TapUpDetails details, PhotoViewControllerValue controllerValue) async {
    if (_selectedImage == null || _imageSize == null) return;

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
      debugPrint(
          'Invalid coordinates: ($imageX, $imageY) - outside image bounds');
      return;
    }

    debugPrint('Tap coordinates on image: ($imageX, $imageY)');

    // Check if too close to existing sensors
    if (_isTooCloseToExistingSensor(imageX, imageY)) {
      _showTooCloseWarning();
      return;
    }

    debugPrint('Opening sensor selection dialog...');
    final selectedSensorId = await _showSensorSelectionDialog();
    debugPrint('Selected sensor ID: $selectedSensorId');
    if (selectedSensorId == null) return;

    // Get the selected sensor from the monitoring state
    final monitoringState = context.read<ProjectDashboardCubit>().state;
    debugPrint('Monitoring state type: ${monitoringState.runtimeType}');
    if (monitoringState is! ProjectDashboardMonitoringSuccess) {
      debugPrint('Invalid monitoring state');
      return;
    }

    debugPrint('Looking for sensor with ID: $selectedSensorId');
    Sensor? selectedSensor;
    outer:
    for (final monitoring
        in monitoringState.monitoringResponse.monitorings ?? []) {
      debugPrint('Checking monitoring: ${monitoring.name}');
      for (final usedSensor in monitoring.usedSensors ?? []) {
        debugPrint('Checking used sensor: ${usedSensor.name}');
        for (final sensor in usedSensor.sensors ?? []) {
          debugPrint(
              'Comparing sensor ID ${sensor.sensorId} with $selectedSensorId');
          if (sensor.sensorId.toString() == selectedSensorId) {
            selectedSensor = sensor;
            debugPrint('Found matching sensor: ${sensor.name}');
            break outer;
          }
        }
      }
    }

    if (selectedSensor == null) {
      debugPrint('Selected sensor not found in monitoring state');
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
    final updatedSensor = Sensor(
      sensorId: selectedSensor.sensorId,
      name: selectedSensor.name,
      uuid: selectedSensor.uuid,
      usedSensor: selectedSensor.usedSensor,
      cloudHub: selectedSensor.cloudHub,
      installDate: selectedSensor.installDate,
      typeId: selectedSensor.typeId,
      dataSource: selectedSensor.dataSource,
      readingsPerDay: selectedSensor.readingsPerDay,
      active: selectedSensor.active,
      coordinateX: imageX,
      coordinateY: imageY,
      coordinateZ: selectedSensor.coordinateZ,
      longitude: selectedSensor.longitude,
      latitude: selectedSensor.latitude,
      calibrated: selectedSensor.calibrated,
      calibrationDate: selectedSensor.calibrationDate,
      calibrationComments: selectedSensor.calibrationComments,
      event: selectedSensor.event,
      eventLastStatus: selectedSensor.eventLastStatus,
      status: selectedSensor.status,
      cloudHubTime: selectedSensor.cloudHubTime,
      sendTime: selectedSensor.sendTime,
    );

    debugPrint('About to add sensor to placed sensors list');
    setState(() {
      _placedSensors.add(updatedSensor);
    });
    debugPrint(
        'Added sensor to placed sensors list. Total count: ${_placedSensors.length}');

    debugPrint('''
Placed sensor:
- Name: ${updatedSensor.name}
- ID: ${updatedSensor.sensorId}
- UUID: ${updatedSensor.uuid}
- Type: ${updatedSensor.typeId}
- Status: ${updatedSensor.status}
- Active: ${updatedSensor.active}
- Event: ${updatedSensor.event}
- Event Last Status: ${updatedSensor.eventLastStatus}
- Coordinates: (${imageX.toStringAsFixed(1)}, ${imageY.toStringAsFixed(1)})
- Full sensor object: ${updatedSensor.toJson()}
''');
  }

  Future<String?> _showSensorSelectionDialog() async {
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

  void _handleSave() {
    if (_selectedImage == null || _imageSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected'),
        ),
      );
      return;
    }

    if (_placedSensors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sensors placed on the image'),
        ),
      );
      return;
    }

    // Print sensor IDs
    debugPrint('\nPlaced Sensors Information:');
    debugPrint('Sensor IDs: ${_placedSensors.map((s) => s.sensorId).toList()}');
    debugPrint('\nCoordinate Ranges:');
    debugPrint(
        'X-axis: starts from 0.00 to ${_imageSize!.width.toStringAsFixed(2)}');
    debugPrint(
        'Y-axis: starts from 0.00 to ${_imageSize!.height.toStringAsFixed(2)}\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) =>
          sl<ProjectDashboardCubit>()..getMonitoring(widget.projectId),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Place Sensors on Image',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (_selectedImage != null) ...[
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
          ],
        ),
        body: _selectedImage == null
            ? _ImagePlaceholder(pickImage: _pickImage)
            : Stack(
                children: [
                  PhotoView(
                    imageProvider: FileImage(File(_selectedImage!.path)),
                    controller: _photoViewController,
                    basePosition: Alignment.center,
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    backgroundDecoration: BoxDecoration(
                      color: colorScheme.surface,
                    ),
                    onTapUp: (context, details, controllerValue) =>
                        _onImageTap(details, controllerValue),
                  ),
                  if (_placedSensors.isNotEmpty)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ValueListenableBuilder<int>(
                          valueListenable: _repaintNotifier,
                          builder: (context, _, __) {
                            return RepaintBoundary(
                              child: CustomPaint(
                                painter: SensorOverlayPainter(
                                  sensors: _placedSensors,
                                  controllerValue: _photoViewController.value,
                                  imageSize: _imageSize!,
                                ),
                              ),
                            );
                          },
                        ),
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
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final VoidCallback pickImage;

  const _ImagePlaceholder({required this.pickImage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Image Selected',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Select Image'),
          ),
        ],
      ),
    );
  }
}

class SensorOverlayPainter extends CustomPainter {
  final List<Sensor> sensors;
  final PhotoViewControllerValue controllerValue;
  final ui.Size imageSize;

  SensorOverlayPainter({
    required this.sensors,
    required this.controllerValue,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size viewportSize) {
    final scale = controllerValue.scale ?? 1.0;
    final position = controllerValue.position;

    // Calculate the center of the viewport
    final viewportCenter = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );

    for (final sensor in sensors) {
      // Convert image coordinates (from bottom-left) to screen coordinates
      final screenX = viewportCenter.dx +
          ((sensor.coordinateX! - imageSize.width / 2) * scale) +
          position.dx;
      // Invert Y coordinate since sensor coordinates are from bottom-left
      final screenY = viewportCenter.dy +
          ((imageSize.height - sensor.coordinateY! - imageSize.height / 2) *
              scale) +
          position.dy;

      debugPrint(
          'Drawing sensor at screen coordinates: ($screenX, $screenY) from image coordinates: (${sensor.coordinateX}, ${sensor.coordinateY})');

      // Draw sensor indicator
      final paint = Paint()
        ..color = _sensorColor(sensor.status)
        ..style = PaintingStyle.fill;

      // Draw main circle
      canvas.drawCircle(
        Offset(screenX, screenY),
        8 * scale.clamp(0.5, 2.0),
        paint,
      );

      // Draw coordinate text
      final textPainter = TextPainter(
        text: TextSpan(
          text:
              '(${sensor.coordinateX?.toStringAsFixed(0) ?? '0'}, ${sensor.coordinateY?.toStringAsFixed(0) ?? '0'})',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12 * scale.clamp(0.5, 1.5),
            shadows: [Shadow(blurRadius: 2 * scale, color: Colors.black)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          screenX - textPainter.width / 2,
          screenY + 10 * scale.clamp(0.5, 1.5),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(SensorOverlayPainter oldDelegate) {
    return sensors != oldDelegate.sensors ||
        controllerValue != oldDelegate.controllerValue ||
        imageSize != oldDelegate.imageSize;
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
