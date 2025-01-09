import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/cubit/ticket_messages_cubit.dart';
import 'package:pulsehub/features/project_dashboard/data/models/sensor_activity_log_model.dart'
    as activity_log;
import 'package:pulsehub/features/project_dashboard/data/models/sensor_data_model.dart';
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
          .getSensorActivityLog(widget.sensor.sensorId ?? 0);
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

          int globalIndex = 0;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowColor: WidgetStateColor.resolveWith(
                      (states) => Theme.of(context).colorScheme.primary),
                  columns: const [
                    DataColumn(
                        label: Text('Event',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Date',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Description',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Actions',
                            style: TextStyle(color: Colors.white))),
                  ],
                  rows: tickets.map((ticket) {
                    final DateTime createdAt =
                        DateTime.parse(ticket.createdAt ?? '');
                    final String formattedDate =
                        '${createdAt.month}/${createdAt.day}/${createdAt.year}, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')} ${createdAt.hour >= 12 ? 'PM' : 'AM'}';

                    final rowColor = globalIndex % 2 == 0
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.surface;

                    globalIndex++;

                    return DataRow(
                      color: WidgetStateColor.resolveWith((states) => rowColor),
                      cells: [
                        DataCell(Text(ticket.name ?? 'Unknown')),
                        DataCell(Text(formattedDate)),
                        DataCell(
                          SizedBox(
                            width: 300,
                            child: Text(
                              ticket.description ?? 'No description available',
                              softWrap: true,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Icon(
                                ticket.open == true
                                    ? Icons.warning
                                    : Icons.check_circle,
                                color: ticket.open == true
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ticket.open == true ? 'Open' : 'Closed',
                                style: TextStyle(
                                  color: ticket.open == true
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.filled(
                                icon: const Icon(Icons.message, size: 20),
                                onPressed: () {
                                  _showTicketMessagesDialog(
                                      context, ticket, formattedDate);
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  // Edit functionality will be implemented later
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  void _showTicketMessagesDialog(
      BuildContext context, activity_log.Ticket ticket, String formattedDate) {
    final messagesCubit = sl<TicketMessagesCubit>();
    messagesCubit.getTicketMessages(ticket.ticketId ?? 0);

    // Controller for the message input
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ProjectDashboardCubit>()),
          BlocProvider(create: (context) => messagesCubit),
        ],
        child: BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
          listener: (context, state) {
            if (state is ProjectDashboardMarkMessageAsSeenSuccess) {
              // Message marked as seen successfully
            } else if (state is ProjectDashboardMarkMessageAsSeenFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Failed to mark message as seen: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocListener<TicketMessagesCubit, TicketMessagesState>(
            listener: (context, state) {
              if (state is CreateTicketMessageSuccess) {
                messageController.clear();
                messagesCubit.getTicketMessages(ticket.ticketId ?? 0);
              } else if (state is CreateTicketMessageFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to send message: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is TicketMessagesSuccess) {
                // Mark all unread messages as seen
                final currentUserId = UserManager().user?.userId;
                for (final message
                    in state.ticketMessagesModel.ticketMessages ?? []) {
                  if (!(message.seen?.contains(currentUserId) ?? false)) {
                    context
                        .read<ProjectDashboardCubit>()
                        .markMessageAsSeen(message.ticketMessageId ?? 0);
                  }
                }
              }
            },
            child: Dialog(
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text('Event: ${ticket.name}'),
                    const SizedBox(height: 8),
                    Text('Description: ${ticket.description}'),
                    const SizedBox(height: 8),
                    Text('Date: $formattedDate'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: '),
                        Icon(
                          ticket.open == true
                              ? Icons.warning
                              : Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.open == true ? 'Open' : 'Closed',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ticket Messages',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<TicketMessagesCubit, TicketMessagesState>(
                      builder: (context, state) {
                        if (state is TicketMessagesLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is TicketMessagesFailure) {
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        if (state is TicketMessagesSuccess) {
                          final messages =
                              state.ticketMessagesModel.ticketMessages;
                          if (messages == null || messages.isEmpty) {
                            return const Text('No messages available');
                          }

                          return Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final DateTime messageDate =
                                    message.createdAt ?? DateTime.now();
                                final String messageFormattedDate =
                                    '${messageDate.month}/${messageDate.day}/${messageDate.year}, ${messageDate.hour}:${messageDate.minute.toString().padLeft(2, '0')}:${messageDate.second.toString().padLeft(2, '0')} ${messageDate.hour >= 12 ? 'PM' : 'AM'}';

                                final currentUserId =
                                    UserManager().user?.userId;
                                final isSeenByCurrentUser =
                                    message.seen?.contains(currentUserId) ??
                                        false;
                                final isCurrentUserMessage =
                                    message.user == currentUserId;

                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(isCurrentUserMessage
                                      ? 'You'
                                      : 'User ${message.user}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(messageFormattedDate),
                                      Text(message.message ?? ''),
                                      Row(
                                        children: [
                                          if (isCurrentUserMessage) ...[
                                            Icon(
                                              Icons.done_all,
                                              size: 16,
                                              color: isSeenByCurrentUser
                                                  ? Colors.grey
                                                  : Colors.grey
                                                      .withOpacity(0.5),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          InkWell(
                                            onTap: () {
                                              if (message.seen?.isNotEmpty ==
                                                  true) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Delivered to'),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            '${message.seen?.length} user${message.seen!.length > 1 ? 's' : ''} have seen this message'),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                            'User IDs: ${message.seen?.join(", ")}'),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child:
                                                            const Text('Close'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              isCurrentUserMessage
                                                  ? 'Opened by you'
                                                  : message.seen?.isNotEmpty ==
                                                          true
                                                      ? 'Delivered to ${message.seen?.length} user${message.seen!.length > 1 ? 's' : ''}'
                                                      : 'Not delivered yet',
                                              style: TextStyle(
                                                color: isSeenByCurrentUser
                                                    ? Colors.grey
                                                    : Colors.grey
                                                        .withOpacity(0.5),
                                                fontSize: 12,
                                                decoration: message
                                                            .seen?.isNotEmpty ==
                                                        true
                                                    ? TextDecoration.underline
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const Text('No messages available');
                      },
                    ),
                    const SizedBox(height: 16),
                    // Message input field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            final message = messageController.text.trim();
                            if (message.isNotEmpty) {
                              context
                                  .read<TicketMessagesCubit>()
                                  .createTicketMessage(
                                      ticket.ticketId ?? 0, message);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              const Center(child: Text('Calibration tab content coming soon')),
              const Center(child: Text('Thresholds tab content coming soon')),
              const Center(child: Text('Data Source tab content coming soon')),
              _buildEventsLogTab(),
            ],
          ),
        ),
      ],
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
