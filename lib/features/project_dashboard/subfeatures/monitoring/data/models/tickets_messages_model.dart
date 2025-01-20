import 'package:json_annotation/json_annotation.dart';

part 'tickets_messages_model.g.dart';

@JsonSerializable()
class TicketMessagesModel {
  @JsonKey(name: "success")
  final bool? success;
  @JsonKey(name: "ticket_messages")
  final List<TicketMessage>? ticketMessages;

  TicketMessagesModel({
    this.success,
    this.ticketMessages,
  });

  TicketMessagesModel copyWith({
    bool? success,
    List<TicketMessage>? ticketMessages,
  }) =>
      TicketMessagesModel(
        success: success ?? this.success,
        ticketMessages: ticketMessages ?? this.ticketMessages,
      );

  factory TicketMessagesModel.fromJson(Map<String, dynamic> json) =>
      _$TicketMessagesModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketMessagesModelToJson(this);
}

@JsonSerializable()
class TicketMessage {
  @JsonKey(name: "ticket_id")
  final int? ticketId;
  @JsonKey(name: "ticket_message_id")
  final int? ticketMessageId;
  @JsonKey(name: "created_at")
  final DateTime? createdAt;
  @JsonKey(name: "user")
  final int? user;
  @JsonKey(name: "message")
  final String? message;
  @JsonKey(name: "seen")
  final List<dynamic>? seen;

  TicketMessage({
    this.ticketId,
    this.ticketMessageId,
    this.createdAt,
    this.user,
    this.message,
    this.seen,
  });

  TicketMessage copyWith({
    int? ticketId,
    int? ticketMessageId,
    DateTime? createdAt,
    int? user,
    String? message,
    List<dynamic>? seen,
  }) =>
      TicketMessage(
        ticketId: ticketId ?? this.ticketId,
        ticketMessageId: ticketMessageId ?? this.ticketMessageId,
        createdAt: createdAt ?? this.createdAt,
        user: user ?? this.user,
        message: message ?? this.message,
        seen: seen ?? this.seen,
      );

  factory TicketMessage.fromJson(Map<String, dynamic> json) =>
      _$TicketMessageFromJson(json);

  Map<String, dynamic> toJson() => _$TicketMessageToJson(this);
}
