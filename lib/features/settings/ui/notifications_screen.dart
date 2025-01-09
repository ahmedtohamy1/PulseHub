import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/cubit/ticket_messages_cubit.dart';
import 'package:pulsehub/features/settings/cubit/settings_cubit.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ProjectDashboardCubit _dashboardCubit;

  void _showTicketMessagesDialog(BuildContext context, String ticketName,
      String? ticketDescription, int ticketId, DateTime? createdAt) {
    final messagesCubit = sl<TicketMessagesCubit>();
    messagesCubit.getTicketMessages(ticketId);

    final formattedDate = createdAt != null
        ? '${createdAt.month}/${createdAt.day}/${createdAt.year}, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')} ${createdAt.hour >= 12 ? 'PM' : 'AM'}'
        : 'Unknown date';

    // Controller for the message input
    final TextEditingController messageController = TextEditingController();

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
                messagesCubit.getTicketMessages(ticketId);
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
                    Text('Event: $ticketName'),
                    const SizedBox(height: 8),
                    Text(
                        'Description: ${ticketDescription ?? 'No description available'}'),
                    const SizedBox(height: 8),
                    Text('Date: $formattedDate'),
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
                              messagesCubit.createTicketMessage(
                                  ticketId, message);
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
                  _showTicketMessagesDialog(
                    context,
                    ticketName,
                    ticketDescription,
                    ticketId,
                    DateTime.tryParse(ticket.createdAt ?? ''),
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
    context.read<SettingsCubit>().getNotifications();
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
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton.filled(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_outlined)),
                  const SizedBox(width: 6),
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
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    );
                  }

                  if (state is GetNotificationsSuccess) {
                    final notifications = state.response.notifications
                            ?.where((notification) =>
                                notification.warnings?.any((warning) =>
                                    warning.ticketsDetails?.isNotEmpty ==
                                    true) ==
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
                                                  ticketData
                                                          .ticket.ticketName ??
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
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
      ),
    );
  }
}
