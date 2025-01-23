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

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown date';
    try {
      // Convert UTC to local time
      final localDateTime = dateTime.toLocal();

      // Format date
      final date =
          '${localDateTime.month}/${localDateTime.day}/${localDateTime.year}';

      // Format time
      final hour = localDateTime.hour % 12 == 0 ? 12 : localDateTime.hour % 12;
      final minute = localDateTime.minute.toString().padLeft(2, '0');
      final period = localDateTime.hour >= 12 ? 'PM' : 'AM';

      return '$date, $hour:$minute $period';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _showMessageInfoScreen(
      BuildContext context, dynamic message, List<dynamic>? users) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageInfoScreen(
          message: message,
          ticketUsers: users,
        ),
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
              if (currentUserId != null) {
                for (final message
                    in state.ticketMessagesModel.ticketMessages ?? []) {
                  // Skip messages sent by current user
                  if (message.user == currentUserId) continue;

                  // Check if message is not already seen by current user
                  final isAlreadySeen = message.seen?.any((seenInfo) =>
                          seenInfo['user_details'] != null &&
                          seenInfo['user_details']['user_id'] ==
                              currentUserId) ??
                      false;

                  // Only mark unseen messages that have a valid ID
                  if (!isAlreadySeen && message.ticketMessageId != null) {
                    context
                        .read<ProjectDashboardCubit>()
                        .markMessageAsSeen(message.ticketMessageId!);
                  }
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
                                    _formatDateTime(messageDate);

                                final currentUserId =
                                    UserManager().user?.userId;
                                final isSeenByCurrentUser =
                                    message.seen?.any((seenInfo) {
                                          if (seenInfo is! Map<String, dynamic>)
                                            return false;
                                          final userDetails =
                                              seenInfo['user_details'];
                                          if (userDetails
                                              is! Map<String, dynamic>)
                                            return false;
                                          return userDetails['user_id'] ==
                                              currentUserId;
                                        }) ??
                                        false;
                                final isCurrentUserMessage =
                                    message.user == currentUserId;

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: !isCurrentUserMessage &&
                                            !isSeenByCurrentUser
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withValues(alpha: 0.3)
                                        : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: !isCurrentUserMessage &&
                                            !isSeenByCurrentUser
                                        ? Border(
                                            left: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 4,
                                            ),
                                          )
                                        : null,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                  child: Text(
                                                    'U',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSecondaryContainer,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'User ${message.user}',
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
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!isCurrentUserMessage &&
                                              !isSeenByCurrentUser)
                                            InkWell(
                                              onTap: () {
                                                if (message.ticketMessageId !=
                                                    null) {
                                                  context
                                                      .read<
                                                          ProjectDashboardCubit>()
                                                      .markMessageAsSeen(message
                                                          .ticketMessageId!);
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'New',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                ),
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
                                                _showMessageInfoScreen(context,
                                                    message, ticketUsers);
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

class MessageInfoScreen extends StatelessWidget {
  final dynamic message;
  final List<dynamic>? ticketUsers;

  const MessageInfoScreen({
    super.key,
    required this.message,
    this.ticketUsers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final seenUsers = message.seen
            ?.where((userId) => userId['user_details'] != null)
            .toList() ??
        [];
    final totalDelivered = ticketUsers?.length ?? 0;
    final totalSeen = seenUsers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message info'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message Content
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message ?? '',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDateTime(message.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(
                    context,
                    icon: Icons.done_all,
                    title: 'Delivered to',
                    count: totalDelivered,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    icon: Icons.visibility,
                    title: 'Seen by',
                    count: totalSeen,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Delivered Section
            if (ticketUsers != null && ticketUsers!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Delivered to',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ticketUsers!.length,
                itemBuilder: (context, index) {
                  final user = ticketUsers![index];
                  final isSeen = message.seen?.any((seenUser) =>
                          seenUser['user_details'] != null &&
                          seenUser['user_details']['user_id'] == user.userId) ??
                      false;

                  return _buildUserListTile(
                    context,
                    name: '${user.firstName} ${user.lastName}',
                    subtitle: isSeen ? 'Seen' : 'Delivered',
                    icon: isSeen ? Icons.visibility : Icons.done_all,
                    iconColor: isSeen
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            // Seen Section
            if (seenUsers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Seen by',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: seenUsers.length,
                itemBuilder: (context, index) {
                  final user = seenUsers[index];
                  return _buildUserListTile(
                    context,
                    name:
                        '${user['user_details']['first_name']} ${user['user_details']['last_name']}',
                    subtitle: _formatDateTime(_parseDateTime(user['seen_at'])),
                    icon: Icons.visibility,
                    iconColor: colorScheme.primary,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  '$count ${count == 1 ? 'user' : 'users'}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListTile(
    BuildContext context, {
    required String name,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        trailing: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown date';
    try {
      // Convert UTC to local time
      final localDateTime = dateTime.toLocal();

      // Format date
      final date =
          '${localDateTime.month}/${localDateTime.day}/${localDateTime.year}';

      // Format time
      final hour = localDateTime.hour % 12 == 0 ? 12 : localDateTime.hour % 12;
      final minute = localDateTime.minute.toString().padLeft(2, '0');
      final period = localDateTime.hour >= 12 ? 'PM' : 'AM';

      return '$date, $hour:$minute $period';
    } catch (e) {
      return 'Invalid date';
    }
  }

  DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      // Parse ISO 8601 format (e.g. "2025-01-09T18:13:09.479386Z")
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      return null;
    }
  }
}
