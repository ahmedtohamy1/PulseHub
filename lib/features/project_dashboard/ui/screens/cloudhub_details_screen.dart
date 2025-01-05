import 'package:flutter/material.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_details.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CloudHubDetailsScreen extends StatelessWidget {
  final MonitoringCloudhubDetails cloudHub;

  const CloudHubDetailsScreen({
    super.key,
    required this.cloudHub,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Text(
                  'CloudHub QR Code',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: _generateQrData(),
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ],
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
