import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/cubit/ticket_messages_cubit.dart';
import 'package:pulsehub/features/settings/cubit/settings_cubit.dart';
import 'package:pulsehub/features/settings/ui/screens/ticket_messages_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ProjectDashboardCubit _dashboardCubit;

  void _handleCardTap(BuildContext context, String ticketName,
      String? ticketDescription, int sensorId) {
    final dashboardCubit = context.read<ProjectDashboardCubit>();
    dashboardCubit.getSensorActivityLog(sensorId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: dashboardCubit,
        child: BlocListener<ProjectDashboardCubit, ProjectDashboardState>(
          listener: (context, state) {
            if (state is ProjectDashboardSensorActivityLogSuccess) {
              final tickets = state.sensorActivityLog.sensorSignalsTickets;
              if (tickets != null && tickets.isNotEmpty) {
                // Find the matching ticket by name
                final ticket = tickets.firstWhere(
                  (t) => t.name == ticketName,
                  orElse: () =>
                      tickets.first, // Fallback to first ticket if not found
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext); // Close the loading dialog
                }

                final ticketId = ticket.ticketId ?? -1;
                if (ticketId != -1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) => sl<TicketMessagesCubit>(),
                          ),
                          BlocProvider(
                            create: (context) => sl<ProjectDashboardCubit>()
                              ..getSensorActivityLog(sensorId),
                          ),
                        ],
                        child: TicketMessagesScreen(
                          ticketName: ticketName,
                          ticketDescription: ticketDescription,
                          ticketId: ticketId,
                          createdAt: DateTime.tryParse(ticket.createdAt ?? ''),
                        ),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Failed to load ticket details: Invalid ticket ID'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else if (state is ProjectDashboardSensorActivityLogFailure) {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Failed to load ticket details: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _dashboardCubit = sl<ProjectDashboardCubit>();
    context.read<SettingsCubit>()
      ..getUnseenMessages()
      ..getNotifications();
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _dashboardCubit,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Projects with Warnings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                if (state is GetNotificationsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GetNotificationsError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }

                if (state is GetNotificationsSuccess) {
                  final notifications = state.response.notifications
                          ?.where((notification) =>
                              notification.warnings?.any((warning) =>
                                  warning.ticketsDetails?.isNotEmpty == true) ==
                              true)
                          .toList() ??
                      [];

                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text(
                        'No warnings found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final allTickets =
                          notification.warnings?.expand((warning) {
                                return (warning.ticketsDetails ?? [])
                                    .map((ticket) => (
                                          ticket: ticket,
                                          sensorId: warning.sensorId,
                                        ));
                              }).toList() ??
                              [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index > 0) const SizedBox(height: 24),
                          Text(
                            notification.title ?? 'Unknown Project',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allTickets.length,
                            itemBuilder: (context, ticketIndex) {
                              final ticketData = allTickets[ticketIndex];
                              final sensorId = ticketData.sensorId ?? 0;
                              return InkWell(
                                onTap: () => _handleCardTap(
                                  context,
                                  ticketData.ticket.ticketName ??
                                      'Unknown Ticket',
                                  ticketData.ticket.ticketDescription,
                                  sensorId,
                                ),
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                ticketData.ticket.ticketName ??
                                                    'No warning title',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            if (ticketData.ticket
                                                        .unseenMessages !=
                                                    null &&
                                                ticketData.ticket
                                                        .unseenMessages! >
                                                    0)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${ticketData.ticket.unseenMessages}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (ticketData
                                                .ticket.ticketDescription !=
                                            null) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            ticketData
                                                .ticket.ticketDescription!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
