import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pulsehub/features/project_dashboard/data/models/sensor_data_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final filterMap = {
  "All": null,
  "Operational": "green",
  "Warning": "orange",
  "Critical": "red",
};

class SensorDetailsScreen extends StatefulWidget {
  final Sensor sensor;

  const SensorDetailsScreen({super.key, required this.sensor});

  @override
  State<SensorDetailsScreen> createState() => _SensorDetailsScreenState();
}

class _SensorDetailsScreenState extends State<SensorDetailsScreen> {
  final GlobalKey qrKey = GlobalKey();

  Future<void> _downloadQrCode() async {
    try {
      final boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName =
          'sensor_qr_${widget.sensor.name.replaceAll(' ', '_')}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.png';
      final tempFile = File('${tempDir.path}\\$fileName');
      await tempFile.writeAsBytes(pngBytes);

      if (mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final position = box!.localToGlobal(Offset.zero);
        final size = box.size;

        await Share.shareXFiles(
          [XFile(tempFile.path)],
          subject: 'Sensor QR Code - ${widget.sensor.name}',
          sharePositionOrigin: Rect.fromLTWH(
            position.dx,
            position.dy,
            size.width,
            size.height / 2,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save QR code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEventStatusRow(String label, String event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  event == 'green'
                      ? Icons.check_circle
                      : event == 'orange'
                          ? Icons.warning
                          : Icons.error,
                  color: event == 'green'
                      ? Colors.green
                      : event == 'orange'
                          ? Colors.orange
                          : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  event == 'green'
                      ? 'Operational'
                      : event == 'orange'
                          ? 'Warning'
                          : 'Critical',
                  style: TextStyle(
                    color: event == 'green'
                        ? Colors.green
                        : event == 'orange'
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensorJson = widget.sensor.toJson();
    final qrData = jsonEncode(sensorJson);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton.filled(
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.sensor.name.isNotEmpty
                      ? widget.sensor.name
                      : 'Sensor Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Sensor Name:', widget.sensor.name),
                    _buildInfoRow('UUID:', widget.sensor.uuid),
                    _buildInfoRow('Install Date:',
                        widget.sensor.installDate?.toString() ?? 'N/A'),
                    _buildInfoRow('Readings per Day:',
                        widget.sensor.readingsPerDay?.toString() ?? 'N/A'),
                    _buildInfoRow(
                        'Active:', widget.sensor.active ? 'Yes' : 'No'),
                    _buildEventStatusRow('Event Status:', widget.sensor.event),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calibration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        'Calibrated:', widget.sensor.calibrated ? 'Yes' : 'No'),
                    _buildInfoRow('Calibration Date:',
                        widget.sensor.calibrationDate?.toString() ?? 'N/A'),
                    _buildInfoRow('Calibration Comments:',
                        widget.sensor.calibrationComments?.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Coordinate X:',
                        widget.sensor.coordinateX?.toString() ?? 'N/A'),
                    _buildInfoRow('Coordinate Y:',
                        widget.sensor.coordinateY?.toString() ?? 'N/A'),
                    _buildInfoRow('Coordinate Z:',
                        widget.sensor.coordinateZ?.toString() ?? 'N/A'),
                    _buildInfoRow('Latitude:',
                        widget.sensor.latitude?.toString() ?? 'N/A'),
                    _buildInfoRow('Longitude:',
                        widget.sensor.longitude?.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sensor QR Code',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        IconButton.filled(
                          icon: const Icon(Icons.download),
                          onPressed: _downloadQrCode,
                          tooltip: 'Download QR Code',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RepaintBoundary(
                        key: qrKey,
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
