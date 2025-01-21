import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/project_dashboard/cubit/project_dashboard_cubit.dart';
import 'package:pulsehub/features/project_dashboard/cubit/ticket_messages_cubit.dart';

class TicketMessagesScreen extends StatefulWidget {
  final String ticketName;
  final String? ticketDescription;
  final int ticketId;
  final DateTime? createdAt;

  const TicketMessagesScreen({
    super.key,
    required this.ticketName,
    this.ticketDescription,
    required this.ticketId,
    this.createdAt,
  });

  @override
  State<TicketMessagesScreen> createState() => _TicketMessagesScreenState();
}

class _TicketMessagesScreenState extends State<TicketMessagesScreen> {
  late final TextEditingController _messageController;
  late final TicketMessagesCubit _messagesCubit;
  int totalTicketUsers = 0;
  List<dynamic>? ticketUsers;

  void _showDeliveredUsersDialog(
      BuildContext context, dynamic message, List<dynamic> users) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.people,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Delivered to'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${users.length} users should receive this message',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...users.map((user) {
                      final isSeen = message.seen?.any((seenUser) =>
                              seenUser['user_details'] != null &&
                              seenUser['user_details']['user_id'] ==
                                  user.userId) ??
                          false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .shadow
                                  .withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${user.firstName} ${user.lastName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (isSeen)
                              Icon(
                                Icons.done_all,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSeenByDialog(BuildContext context, dynamic message) {
    final seenUsers = message.seen
            ?.where((userId) => userId['user_details'] != null)
            .toList() ??
        [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.visibility,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Seen by'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${seenUsers.length} users have seen this message',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...seenUsers.map((user) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .shadow
                                  .withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${user['user_details']['first_name']} ${user['user_details']['last_name']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.done_all,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String get _formattedDate => widget.createdAt != null
      ? '${widget.createdAt!.month}/${widget.createdAt!.day}/${widget.createdAt!.year}, ${widget.createdAt!.hour}:${widget.createdAt!.minute.toString().padLeft(2, '0')}:${widget.createdAt!.second.toString().padLeft(2, '0')} ${widget.createdAt!.hour >= 12 ? 'PM' : 'AM'}'
      : 'Unknown date';

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messagesCubit = sl<TicketMessagesCubit>();
    _messagesCubit.getTicketMessages(widget.ticketId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ProjectDashboardCubit>()),
        BlocProvider(create: (context) => _messagesCubit),
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
          } else if (state is ProjectDashboardSensorActivityLogSuccess) {
            // Update total ticket users count
            final tickets = state.sensorActivityLog.sensorSignalsTickets;
            if (tickets != null) {
              final ticket = tickets.firstWhere(
                (t) => t.ticketId == widget.ticketId,
                orElse: () => tickets.first,
              );
              setState(() {
                totalTicketUsers = ticket.ticketUsers?.length ?? 0;
                ticketUsers = ticket.ticketUsers;
              });
            }
          }
        },
        child: BlocListener<TicketMessagesCubit, TicketMessagesState>(
          listener: (context, state) {
            if (state is CreateTicketMessageSuccess) {
              _messageController.clear();
              _messagesCubit.getTicketMessages(widget.ticketId);
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
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Ticket Details'),
              centerTitle: true,
            ),
            body: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.ticketName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.ticketDescription != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.ticketDescription!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Created: $_formattedDate',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Messages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          BlocBuilder<TicketMessagesCubit, TicketMessagesState>(
                        builder: (context, state) {
                          if (state is TicketMessagesLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (state is TicketMessagesFailure) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error: ${state.message}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (state is TicketMessagesSuccess) {
                            final messages =
                                state.ticketMessagesModel.ticketMessages;
                            if (messages == null || messages.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No messages yet',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
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

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .shadow
                                            .withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                isCurrentUserMessage
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                            radius: 16,
                                            child: Icon(
                                              Icons.person,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isCurrentUserMessage
                                                      ? 'You'
                                                      : 'User ${message.user}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                                Text(
                                                  messageFormattedDate,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        message.message ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (isCurrentUserMessage) ...[
                                            Icon(
                                              Icons.done_all,
                                              size: 16,
                                              color: isSeenByCurrentUser
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.5),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          InkWell(
                                            onTap: () {
                                              if (ticketUsers != null) {
                                                _showDeliveredUsersDialog(
                                                    context,
                                                    message,
                                                    ticketUsers!);
                                              }
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Delivered to $totalTicketUsers user${totalTicketUsers != 1 ? 's' : ''} (${message.seen?.length ?? 0} received)',
                                                  style: TextStyle(
                                                    color: isSeenByCurrentUser
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant
                                                            .withValues(
                                                                alpha: 0.7),
                                                    fontSize: 12,
                                                    decoration: message.seen
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? TextDecoration
                                                            .underline
                                                        : null,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                InkWell(
                                                  onTap: () {
                                                    if (message
                                                            .seen?.isNotEmpty ==
                                                        true) {
                                                      _showSeenByDialog(
                                                          context, message);
                                                    }
                                                  },
                                                  child: Text(
                                                    'Seen by ${message.seen?.where((userId) => userId['user_details'] != null).length ?? 0} user${message.seen?.where((userId) => userId['user_details'] != null).length != 1 ? 's' : ''}',
                                                    style: TextStyle(
                                                      color: isSeenByCurrentUser
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurfaceVariant
                                                              .withValues(
                                                                  alpha: 0.7),
                                                      fontSize: 12,
                                                      decoration: message.seen
                                                                  ?.isNotEmpty ==
                                                              true
                                                          ? TextDecoration
                                                              .underline
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                          return const Text('No messages available');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            final message = _messageController.text.trim();
                            if (message.isNotEmpty) {
                              _messagesCubit.createTicketMessage(
                                  widget.ticketId, message);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
