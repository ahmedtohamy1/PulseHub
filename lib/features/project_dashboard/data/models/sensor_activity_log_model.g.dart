// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_activity_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorActivityLog _$SensorActivityLogFromJson(Map<String, dynamic> json) =>
    SensorActivityLog(
      success: json['success'] as bool?,
      sensorSignalsTickets: (json['sensor_signals_tickets'] as List<dynamic>?)
          ?.map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SensorActivityLogToJson(SensorActivityLog instance) =>
    <String, dynamic>{
      'success': instance.success,
      'sensor_signals_tickets': instance.sensorSignalsTickets,
    };

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
      ticketId: (json['ticket_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      sensor: (json['sensor'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      open: json['open'] as bool?,
      ticketUsers: (json['ticket_users'] as List<dynamic>?)
          ?.map((e) => TicketUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
      'ticket_id': instance.ticketId,
      'created_at': instance.createdAt,
      'sensor': instance.sensor,
      'name': instance.name,
      'description': instance.description,
      'open': instance.open,
      'ticket_users': instance.ticketUsers,
    };

TicketUser _$TicketUserFromJson(Map<String, dynamic> json) => TicketUser(
      userId: (json['user_id'] as num?)?.toInt(),
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      pictureUrl: json['picture_url'] as String?,
    );

Map<String, dynamic> _$TicketUserToJson(TicketUser instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'picture_url': instance.pictureUrl,
    };
