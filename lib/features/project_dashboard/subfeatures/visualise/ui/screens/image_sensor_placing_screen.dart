import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/sensor_model.dart';
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
  Offset? _lastTapPosition;
  final _photoViewKey = GlobalKey();
  final _scaleStateController = PhotoViewScaleStateController();
  double _currentScale = 1.0;
  Offset _position = Offset.zero;

  @override
  void initState() {
    super.initState();
    _fetchSensors();
  }

  Future<void> _fetchSensors() async {
    final cubit = context.read<ProjectDashboardCubit>();
    // TODO: Implement sensor fetching from cubit
    // For now using mock data
    setState(() {
      _sensors.addAll([
        Sensor(
          id: 'sensor_1',
          name: 'Temperature Sensor 1',
          type: 'Temperature',
          x: 0,
          y: 0,
          status: 'active',
        ),
        Sensor(
          id: 'sensor_2',
          name: 'Humidity Sensor 1',
          type: 'Humidity',
          x: 0,
          y: 0,
          status: 'active',
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _scaleStateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
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

  void _onImageTap(TapUpDetails details) async {
    if (_selectedImage == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // Adjust tap position based on current scale and position
    final adjustedPosition = Offset(
      (localPosition.dx - _position.dx) / _currentScale,
      (localPosition.dy - _position.dy) / _currentScale,
    );

    setState(() {
      _lastTapPosition = localPosition;
    });

    final selectedSensorIds = await _showSensorSelectionDialog();
    if (selectedSensorIds != null && selectedSensorIds.isNotEmpty) {
      final selectedSensor = _sensors.firstWhere(
        (sensor) => sensor.id == selectedSensorIds.first.toString(),
        orElse: () => _sensors.first,
      );

      final newPlacedSensor = Sensor(
        id: selectedSensor.id,
        name: selectedSensor.name,
        type: selectedSensor.type,
        x: adjustedPosition.dx,
        y: adjustedPosition.dy,
        status: selectedSensor.status,
      );

      setState(() {
        _placedSensors.add(newPlacedSensor);
        _lastTapPosition = null;
      });

      debugPrint(
          'Placed sensor at: (${adjustedPosition.dx}, ${adjustedPosition.dy})');
    }
  }

  Future<List<int>?> _showSensorSelectionDialog() async {
    return showDialog<List<int>>(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<ProjectDashboardCubit>(),
        child: SensorSelectionDialog(projectId: widget.projectId),
      ),
    );
  }

  Color _getSensorColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProjectDashboardCubit>(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Scaffold(
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
                if (_selectedImage != null)
                  IconButton(
                    onPressed: () {
                      // TODO: Save sensor placements
                    },
                    icon: const Icon(Icons.save),
                  ),
              ],
            ),
            body: _selectedImage == null
                ? Center(
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
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Select Image'),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      GestureDetector(
                        onTapUp: _onImageTap,
                        child: PhotoView(
                          key: _photoViewKey,
                          imageProvider: FileImage(File(_selectedImage!.path)),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                          backgroundDecoration: BoxDecoration(
                            color: colorScheme.surface,
                          ),
                          onTapUp: (context, details, controllerValue) {
                            _onImageTap(details);
                          },
                          onScaleEnd: (context, details, controllerValue) {
                            if (!mounted) return;
                            setState(() {
                              _currentScale = controllerValue.scale ?? 1.0;
                              _position = controllerValue.position;
                            });
                          },
                        ),
                      ),
                      if (_placedSensors.isNotEmpty)
                        CustomPaint(
                          painter: SensorOverlayPainter(
                            sensors: _placedSensors,
                            scale: _currentScale,
                            position: _position,
                          ),
                        ),
                      if (_lastTapPosition != null)
                        Positioned(
                          left: _lastTapPosition!.dx - 12,
                          top: _lastTapPosition!.dy - 12,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Placed Sensors (${_placedSensors.length})',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                if (_placedSensors.isEmpty)
                                  Text(
                                    'No sensors placed',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                else
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      maxWidth: 300,
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: _placedSensors.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final sensor = _placedSensors[index];
                                        return ListTile(
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                          leading: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color:
                                                  _getSensorColor(sensor.status)
                                                      .withOpacity(0.2),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _getSensorColor(
                                                    sensor.status),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            '${sensor.name} (${sensor.x.toStringAsFixed(1)}, ${sensor.y.toStringAsFixed(1)})',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            sensor.type,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20),
                                            onPressed: () {
                                              setState(() {
                                                _placedSensors.removeAt(index);
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class SensorOverlayPainter extends CustomPainter {
  final List<Sensor> sensors;
  final double scale;
  final Offset position;

  SensorOverlayPainter({
    required this.sensors,
    required this.scale,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final sensor in sensors) {
      // Transform the sensor position based on scale and position
      final adjustedPosition = Offset(
        sensor.x * scale + position.dx,
        sensor.y * scale + position.dy,
      );

      // Draw sensor circle
      final circlePaint = Paint()
        ..color = _getSensorColor(sensor.status)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = _getSensorColor(sensor.status)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      const radius = 12.0;

      // Draw outer glow
      final glowPaint = Paint()
        ..color = _getSensorColor(sensor.status).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(adjustedPosition, radius + 4, glowPaint);

      // Draw main circle
      canvas.drawCircle(adjustedPosition, radius, circlePaint);
      canvas.drawCircle(adjustedPosition, radius, borderPaint);

      // Draw sensor name
      final textPainter = TextPainter(
        text: TextSpan(
          text: sensor.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Position text above the circle
      final textOffset = Offset(
        adjustedPosition.dx - textPainter.width / 2,
        adjustedPosition.dy - radius - textPainter.height - 4,
      );
      textPainter.paint(canvas, textOffset);

      // Draw type indicator
      final typeTextPainter = TextPainter(
        text: TextSpan(
          text: sensor.type,
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      typeTextPainter.layout();

      // Position type text below the circle
      final typeOffset = Offset(
        adjustedPosition.dx - typeTextPainter.width / 2,
        adjustedPosition.dy + radius + 4,
      );
      typeTextPainter.paint(canvas, typeOffset);
    }
  }

  Color _getSensorColor(String status) {
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

  @override
  bool shouldRepaint(covariant SensorOverlayPainter oldDelegate) {
    return sensors != oldDelegate.sensors ||
        scale != oldDelegate.scale ||
        position != oldDelegate.position;
  }
}
