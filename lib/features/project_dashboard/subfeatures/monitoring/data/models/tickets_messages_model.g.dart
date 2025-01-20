// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickets_messages_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketMessagesModel _$TicketMessagesModelFromJson(Map<String, dynamic> json) =>
    TicketMessagesModel(
      success: json['success'] as bool?,
      ticketMessages: (json['ticket_messages'] as List<dynamic>?)
          ?.map((e) => TicketMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TicketMessagesModelToJson(
        TicketMessagesModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'ticket_messages': instance.ticketMessages,
    };

TicketMessage _$TicketMessageFromJson(Map<String, dynamic> json) =>
    TicketMessage(
      ticketId: (json['ticket_id'] as num?)?.toInt(),
      ticketMessageId: (json['ticket_message_id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      user: (json['user'] as num?)?.toInt(),
      message: json['message'] as String?,
      seen: json['seen'] as List<dynamic>?,
    );

Map<String, dynamic> _$TicketMessageToJson(TicketMessage instance) =>
    <String, dynamic>{
      'ticket_id': instance.ticketId,
      'ticket_message_id': instance.ticketMessageId,
      'created_at': instance.createdAt?.toIso8601String(),
      'user': instance.user,
      'message': instance.message,
      'seen': instance.seen,
    };
