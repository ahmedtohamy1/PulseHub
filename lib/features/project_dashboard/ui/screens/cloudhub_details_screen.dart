import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_details.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class CloudHubDetailsScreen extends StatelessWidget {
  final MonitoringCloudhubDetails cloudHub;

  const CloudHubDetailsScreen({
    super.key,
    required this.cloudHub,
  });

  @override
  Widget build(BuildContext context) {
    final qrKey = GlobalKey(); // Key for capturing the QR code widget

    // Generate QR code data
    final qrData = _generateQrData();

    // Function to download and share the QR code
    Future<void> downloadQrCode() async {
      try {
        final boundary =
            qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final now = DateTime.now();
        final fileName =
            'cloudhub_qr_${cloudHub.cloudhub.name.replaceAll(' ', '_')}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.png';
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(pngBytes);

        if (context.mounted) {
          final box = context.findRenderObject() as RenderBox?;
          final position = box!.localToGlobal(Offset.zero);
          final size = box.size;

          await Share.shareXFiles(
            [XFile(tempFile.path)],
            subject: 'CloudHub QR Code - ${cloudHub.cloudhub.name}',
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
              content: Text('Failed to save QR code: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return SingleChildScrollView(
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
                cloudHub.cloudhub.name.isNotEmpty
                    ? cloudHub.cloudhub.name
                    : 'CloudHub Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoSection(
            title: 'Basic Information',
            children: [
              _buildInfoRow('CloudHub Name', cloudHub.cloudhub.name),
              _buildInfoRow('Wi-Fi SSID', cloudHub.cloudhub.wifiSsid),
              _buildInfoRow(
                  'Wi-Fi Password', cloudHub.cloudhub.wifiPassword ?? 'N/A'),
              _buildInfoRow('Protocol', cloudHub.cloudhub.protocol ?? 'N/A'),
              _buildInfoRow(
                  'Timedb Server', cloudHub.cloudhub.timedbServer ?? 'N/A'),
              _buildInfoRow('Timedb Port',
                  cloudHub.cloudhub.timedbPort?.toString() ?? 'N/A'),
              _buildInfoRow('Notes', cloudHub.cloudhub.notes),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'CloudHub QR Code',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton.filled(
                        icon: const Icon(Icons.download),
                        onPressed: downloadQrCode,
                        tooltip: 'Download QR Code',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RepaintBoundary(
                      key: qrKey, // Key for capturing the QR code widget
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _generateQrData() {
    return '''
{
  "cloudHubName": "${cloudHub.cloudhub.name}",
  "wifiSsid": "${cloudHub.cloudhub.wifiSsid}",
  "wifiPassword": "${cloudHub.cloudhub.wifiPassword}",
  "protocol": "${cloudHub.cloudhub.protocol}",
  "timedbServer": "${cloudHub.cloudhub.timedbServer}",
  "timedbPort": ${cloudHub.cloudhub.timedbPort},
  "notes": "${cloudHub.cloudhub.notes}"
}''';
  }
}
