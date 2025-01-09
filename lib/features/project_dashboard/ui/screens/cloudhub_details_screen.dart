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
  late MonitoringCloudhubDetails _cloudHub;
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
    _cloudHub = widget.cloudHub;
    _initControllers();
  }

  void _initControllers() {
    _nameController =
        TextEditingController(text: _cloudHub.cloudhub.name ?? '');
    _wifiSsidController =
        TextEditingController(text: _cloudHub.cloudhub.wifiSsid ?? '');
    _wifiPasswordController =
        TextEditingController(text: _cloudHub.cloudhub.wifiPassword ?? '');
    _protocolController =
        TextEditingController(text: _cloudHub.cloudhub.protocol ?? '');
    _timedbServerController =
        TextEditingController(text: _cloudHub.cloudhub.timedbServer ?? '');
    _timedbPortController =
        TextEditingController(text: _cloudHub.cloudhub.timedbPort ?? '');
    _notesController =
        TextEditingController(text: _cloudHub.cloudhub.notes ?? '');
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
    if (_cloudHub.cloudhub.cloudhubId == null) {
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
          _cloudHub.cloudhub.cloudhubId!,
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
            'cloudhub_qr_${_cloudHub.cloudhub.name?.replaceAll(' ', '_') ?? 'unnamed'}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.png';
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(pngBytes);

        if (context.mounted) {
          final box = context.findRenderObject() as RenderBox?;
          final position = box!.localToGlobal(Offset.zero);
          final size = box.size;

          await Share.shareXFiles(
            [XFile(tempFile.path)],
            subject:
                'CloudHub QR Code - ${_cloudHub.cloudhub.name ?? 'Unnamed CloudHub'}',
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
        } else if (state is ProjectDashboardCreateCloudhubSensorSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sensor created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the CloudHub data to get the updated sensors list
          context
              .read<ProjectDashboardCubit>()
              .getCloudhubData(_cloudHub.cloudhub.cloudhubId!);
        } else if (state is ProjectDashboardCreateCloudhubSensorFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create sensor: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProjectDashboardCloudhubDataSuccess) {
          setState(() {
            _cloudHub = MonitoringCloudhubDetails(
              success: state.cloudhubDetails.success,
              cloudhub: state.cloudhubDetails.cloudhub,
            );
          });
        } else if (state is ProjectDashboardCloudhubDataFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh sensors: ${state.message}'),
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
                  _cloudHub.cloudhub.name?.isNotEmpty == true
                      ? _cloudHub.cloudhub.name!
                      : 'CloudHub Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (!_isEditing) ...[
                  IconButton.filled(
                    icon: const Icon(Icons.sensors),
                    onPressed: () {
                      // Show dialog to enter sensor name
                      final TextEditingController sensorNameController =
                          TextEditingController();
                      final parentContext = context;

                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Add New Sensor'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: sensorNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Sensor Name',
                                  hintText: 'Enter sensor name',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    parentContext
                                        .read<ProjectDashboardCubit>()
                                        .createCloudhubSensor(
                                          _cloudHub.cloudhub.cloudhubId ?? 0,
                                          value.trim(),
                                        );
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              BlocConsumer<ProjectDashboardCubit,
                                  ProjectDashboardState>(
                                bloc:
                                    parentContext.read<ProjectDashboardCubit>(),
                                listener: (context, state) {
                                  if (state
                                      is ProjectDashboardCreateCloudhubSensorSuccess) {
                                    Navigator.pop(dialogContext);
                                    // Refresh CloudHub data to get updated sensors list
                                    parentContext
                                        .read<ProjectDashboardCubit>()
                                        .getCloudhubData(
                                          _cloudHub.cloudhub.cloudhubId ?? 0,
                                        );
                                    ScaffoldMessenger.of(parentContext)
                                        .showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Sensor created successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else if (state
                                      is ProjectDashboardCreateCloudhubSensorFailure) {
                                    ScaffoldMessenger.of(parentContext)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to create sensor: ${state.message}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text('Cancel'),
                                      ),
                                      const SizedBox(width: 8),
                                      if (state
                                          is ProjectDashboardCreateCloudhubSensorLoading)
                                        const CircularProgressIndicator()
                                      else
                                        FilledButton(
                                          onPressed: () {
                                            final sensorName =
                                                sensorNameController.text
                                                    .trim();
                                            if (sensorName.isNotEmpty) {
                                              parentContext
                                                  .read<ProjectDashboardCubit>()
                                                  .createCloudhubSensor(
                                                    _cloudHub.cloudhub
                                                            .cloudhubId ??
                                                        0,
                                                    sensorName,
                                                  );
                                            }
                                          },
                                          child: const Text('Add'),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
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
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Sensors',
              children: [
                if (_cloudHub.cloudhub.sensors?.isEmpty ?? true)
                  const Center(child: Text('No sensors available'))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cloudHub.cloudhub.sensors?.length ?? 0,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final sensor = _cloudHub.cloudhub.sensors![index];
                      final Map<String, dynamic> sensorMap =
                          sensor as Map<String, dynamic>;

                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            // TODO: Navigate to sensor details
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: _getStatusColor(
                                      sensorMap['event'] as String?),
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with name, ID and status
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sensorMap['name'] ??
                                                'Unnamed Sensor',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: ${sensorMap['sensor_id'] ?? 'N/A'}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                            sensorMap['event'] as String?),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getStatusIcon(
                                                sensorMap['event'] as String?),
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            sensorMap['event'] as String? ??
                                                'Unknown',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                // Main info grid
                                Wrap(
                                  spacing: 24,
                                  runSpacing: 16,
                                  children: [
                                    _buildSensorInfoRow(
                                      'UUID',
                                      sensorMap['uuid'] ?? 'N/A',
                                      Icons.fingerprint,
                                      width: 300,
                                    ),
                                    _buildSensorInfoRow(
                                      'Status',
                                      sensorMap['status'] ?? 'N/A',
                                      Icons.info_outline,
                                      width: 150,
                                    ),
                                    _buildSensorInfoRow(
                                      'Active',
                                      sensorMap['active'] == true
                                          ? 'Yes'
                                          : 'No',
                                      Icons.power_settings_new,
                                      color: sensorMap['active'] == true
                                          ? Colors.green
                                          : Colors.red,
                                      width: 120,
                                    ),
                                    _buildSensorInfoRow(
                                      'Calibrated',
                                      sensorMap['calibrated'] == true
                                          ? 'Yes'
                                          : 'No',
                                      Icons.build_outlined,
                                      width: 120,
                                    ),
                                  ],
                                ),
                                if (sensorMap['calibration_date'] != null ||
                                    sensorMap['readings_per_day'] != null ||
                                    sensorMap['install_date'] != null)
                                  const Divider(height: 24),
                                if (sensorMap['calibration_date'] != null ||
                                    sensorMap['readings_per_day'] != null ||
                                    sensorMap['install_date'] != null)
                                  Wrap(
                                    spacing: 24,
                                    runSpacing: 16,
                                    children: [
                                      if (sensorMap['calibration_date'] != null)
                                        _buildSensorInfoRow(
                                          'Calibration Date',
                                          sensorMap['calibration_date'],
                                          Icons.calendar_today,
                                          width: 200,
                                        ),
                                      if (sensorMap['readings_per_day'] != null)
                                        _buildSensorInfoRow(
                                          'Readings/Day',
                                          sensorMap['readings_per_day']
                                              .toString(),
                                          Icons.speed,
                                          width: 150,
                                        ),
                                      if (sensorMap['install_date'] != null)
                                        _buildSensorInfoRow(
                                          'Install Date',
                                          sensorMap['install_date'],
                                          Icons.event,
                                          width: 200,
                                        ),
                                    ],
                                  ),
                                if (sensorMap['coordinate_x'] != null ||
                                    sensorMap['coordinate_y'] != null ||
                                    sensorMap['coordinate_z'] != null ||
                                    sensorMap['latitude'] != null ||
                                    sensorMap['longitude'] != null)
                                  const Divider(height: 24),
                                if (sensorMap['coordinate_x'] != null ||
                                    sensorMap['coordinate_y'] != null ||
                                    sensorMap['coordinate_z'] != null ||
                                    sensorMap['latitude'] != null ||
                                    sensorMap['longitude'] != null)
                                  Wrap(
                                    spacing: 24,
                                    runSpacing: 16,
                                    children: [
                                      if (sensorMap['coordinate_x'] != null ||
                                          sensorMap['coordinate_y'] != null ||
                                          sensorMap['coordinate_z'] != null)
                                        _buildSensorInfoRow(
                                          'Coordinates',
                                          '(${sensorMap['coordinate_x'] ?? 0}, ${sensorMap['coordinate_y'] ?? 0}, ${sensorMap['coordinate_z'] ?? 0})',
                                          Icons.location_on_outlined,
                                          width: 300,
                                        ),
                                      if (sensorMap['latitude'] != null &&
                                          sensorMap['longitude'] != null)
                                        _buildSensorInfoRow(
                                          'GPS',
                                          '${sensorMap['latitude']}, ${sensorMap['longitude']}',
                                          Icons.gps_fixed,
                                          width: 300,
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
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
  "cloudHubName": "${_cloudHub.cloudhub.name ?? ''}",
  "wifiSsid": "${_cloudHub.cloudhub.wifiSsid ?? ''}",
  "wifiPassword": "${_cloudHub.cloudhub.wifiPassword ?? ''}",
  "protocol": "${_cloudHub.cloudhub.protocol ?? ''}",
  "timedbServer": "${_cloudHub.cloudhub.timedbServer ?? ''}",
  "timedbPort": ${_cloudHub.cloudhub.timedbPort ?? 'null'},
  "notes": "${_cloudHub.cloudhub.notes ?? ''}"
}''';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSensorInfoRow(String label, String value, IconData icon,
      {Color? color, double? width}) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Colors.grey[600])?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color ?? Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: color ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'green':
        return Icons.check_circle;
      case 'orange':
        return Icons.warning;
      case 'red':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }
}
