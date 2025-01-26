import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/cubit/ticket_messages_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/sensor_data_model.dart';
import 'package:pulsehub/features/settings/ui/screens/ticket_messages_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

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

class _SensorDetailsScreenState extends State<SensorDetailsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }
    // Events Log tab index is 4
    if (_tabController.index == 4) {
      context
          .read<ProjectDashboardCubit>()
          .getSensorActivityLog(widget.sensor.sensorId);
    }
  }

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

  Widget _buildEventsLogTab() {
    return BlocBuilder<ProjectDashboardCubit, ProjectDashboardState>(
      builder: (context, state) {
        if (state is ProjectDashboardSensorActivityLogLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProjectDashboardSensorActivityLogFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is ProjectDashboardSensorActivityLogSuccess) {
          final tickets = state.sensorActivityLog.sensorSignalsTickets;
          if (tickets == null || tickets.isEmpty) {
            return const Center(child: Text('No activity log data available'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 600,
                  mainAxisExtent: 180,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final DateTime createdAt =
                      DateTime.parse(ticket.createdAt ?? '');
                  final String formattedDate =
                      '${createdAt.month}/${createdAt.day}/${createdAt.year}, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')} ${createdAt.hour >= 12 ? 'PM' : 'AM'}';

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ticket.name ?? 'Unknown Event',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ticket.open == true
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      ticket.open == true
                                          ? Icons.warning
                                          : Icons.check_circle,
                                      size: 14,
                                      color: ticket.open == true
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ticket.open == true ? 'Open' : 'Closed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: ticket.open == true
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Date Row
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 14, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Description
                          Expanded(
                            child: Text(
                              ticket.description ?? 'No description available',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Actions Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton.filled(
                                icon: const Icon(Icons.message, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.green.withOpacity(0.1),
                                  foregroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (context) =>
                                                sl<TicketMessagesCubit>(),
                                          ),
                                          BlocProvider(
                                            create: (context) =>
                                                sl<ProjectDashboardCubit>()
                                                  ..getSensorActivityLog(
                                                      widget.sensor.sensorId),
                                          ),
                                        ],
                                        child: TicketMessagesScreen(
                                          ticketName: ticket.name ?? 'Unknown',
                                          ticketDescription: ticket.description,
                                          ticketId: ticket.ticketId ?? -1,
                                          createdAt: DateTime.tryParse(
                                              ticket.createdAt ?? ''),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                icon: const Icon(Icons.edit, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.green.withOpacity(0.1),
                                  foregroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  // Edit functionality will be implemented later
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
          ),
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                indicatorPadding: EdgeInsets.zero,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Calibration'),
                  Tab(text: 'Thresholds'),
                  Tab(text: 'Data Source'),
                  Tab(text: 'Events Log'),
                ],
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                const Center(
                    child: Text('Calibration tab content coming soon')),
                const Center(child: Text('Thresholds tab content coming soon')),
                const Center(
                    child: Text('Data Source tab content coming soon')),
                _buildEventsLogTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final sensorJson = widget.sensor.toJson();
    final qrData = jsonEncode(sensorJson);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
