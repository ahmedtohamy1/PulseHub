import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_details.dart';
import 'package:pulsehub/features/project_dashboard/data/models/update_cloudhub_request_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class CloudHubDetailsScreen extends StatefulWidget {
  final MonitoringCloudhubDetails cloudHub;

  const CloudHubDetailsScreen({
    super.key,
    required this.cloudHub,
  });

  @override
  State<CloudHubDetailsScreen> createState() => _CloudHubDetailsScreenState();
}

class _CloudHubDetailsScreenState extends State<CloudHubDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _wifiSsidController;
  late TextEditingController _wifiPasswordController;
  late TextEditingController _protocolController;
  late TextEditingController _timedbServerController;
  late TextEditingController _timedbPortController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController =
        TextEditingController(text: widget.cloudHub.cloudhub.name ?? '');
    _wifiSsidController =
        TextEditingController(text: widget.cloudHub.cloudhub.wifiSsid ?? '');
    _wifiPasswordController = TextEditingController(
        text: widget.cloudHub.cloudhub.wifiPassword ?? '');
    _protocolController =
        TextEditingController(text: widget.cloudHub.cloudhub.protocol ?? '');
    _timedbServerController = TextEditingController(
        text: widget.cloudHub.cloudhub.timedbServer ?? '');
    _timedbPortController =
        TextEditingController(text: widget.cloudHub.cloudhub.timedbPort ?? '');
    _notesController =
        TextEditingController(text: widget.cloudHub.cloudhub.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    _protocolController.dispose();
    _timedbServerController.dispose();
    _timedbPortController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (widget.cloudHub.cloudhub.cloudhubId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot update CloudHub: Invalid ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final request = UpdateCloudhubRequestModel(
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
      wifiSsid:
          _wifiSsidController.text.isNotEmpty ? _wifiSsidController.text : null,
      wifiPassword: _wifiPasswordController.text.isNotEmpty
          ? _wifiPasswordController.text
          : null,
      protocol:
          _protocolController.text.isNotEmpty ? _protocolController.text : null,
      timedbServer: _timedbServerController.text.isNotEmpty
          ? _timedbServerController.text
          : null,
      timedbPort: _timedbPortController.text.isNotEmpty
          ? _timedbPortController.text
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await context.read<ProjectDashboardCubit>().updateCloudhub(
          widget.cloudHub.cloudhub.cloudhubId!,
          request,
        );

    if (mounted) {
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrKey = GlobalKey();

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
            'cloudhub_qr_${widget.cloudHub.cloudhub.name?.replaceAll(' ', '_') ?? 'unnamed'}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.png';
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(pngBytes);

        if (context.mounted) {
          final box = context.findRenderObject() as RenderBox?;
          final position = box!.localToGlobal(Offset.zero);
          final size = box.size;

          await Share.shareXFiles(
            [XFile(tempFile.path)],
            subject:
                'CloudHub QR Code - ${widget.cloudHub.cloudhub.name ?? 'Unnamed CloudHub'}',
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

    return BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
      listener: (context, state) {
        if (state is ProjectDashboardUpdateCloudhubSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CloudHub updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProjectDashboardUpdateCloudhubFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update CloudHub: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SingleChildScrollView(
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
                  widget.cloudHub.cloudhub.name?.isNotEmpty == true
                      ? widget.cloudHub.cloudhub.name!
                      : 'CloudHub Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (!_isEditing) ...[
                  IconButton.filled(
                    icon: const Icon(Icons.sensors),
                    onPressed: () {
                      // TODO: Implement add sensor functionality
                    },
                    tooltip: 'Add Sensor',
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
                ] else ...[
                  IconButton.filled(
                    icon: const Icon(Icons.save),
                    onPressed: _saveChanges,
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _initControllers();
                      });
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoSection(
              title: 'Basic Information',
              children: [
                _buildEditableInfoRow(
                  'CloudHub Name',
                  _nameController,
                  _isEditing,
                ),
                _buildEditableInfoRow(
                  'Wi-Fi SSID',
                  _wifiSsidController,
                  _isEditing,
                ),
                _buildEditableInfoRow(
                  'Wi-Fi Password',
                  _wifiPasswordController,
                  _isEditing,
                ),
                _buildEditableInfoRow(
                  'Protocol',
                  _protocolController,
                  _isEditing,
                ),
                _buildEditableInfoRow(
                  'Timedb Server',
                  _timedbServerController,
                  _isEditing,
                ),
                _buildEditableInfoRow(
                  'Timedb Port',
                  _timedbPortController,
                  _isEditing,
                ),
                _buildEditableInfoRow(
                  'Notes',
                  _notesController,
                  _isEditing,
                ),
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
                        key: qrKey,
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

  Widget _buildEditableInfoRow(
    String label,
    TextEditingController controller,
    bool isEditing,
  ) {
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
            child: isEditing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(8),
                      hintText: 'Enter $label',
                    ),
                  )
                : Text(controller.text.isEmpty ? 'N/A' : controller.text),
          ),
        ],
      ),
    );
  }

  String _generateQrData() {
    return '''
{
  "cloudHubName": "${widget.cloudHub.cloudhub.name ?? ''}",
  "wifiSsid": "${widget.cloudHub.cloudhub.wifiSsid ?? ''}",
  "wifiPassword": "${widget.cloudHub.cloudhub.wifiPassword ?? ''}",
  "protocol": "${widget.cloudHub.cloudhub.protocol ?? ''}",
  "timedbServer": "${widget.cloudHub.cloudhub.timedbServer ?? ''}",
  "timedbPort": ${widget.cloudHub.cloudhub.timedbPort ?? 'null'},
  "notes": "${widget.cloudHub.cloudhub.notes ?? ''}"
}''';
  }
}
