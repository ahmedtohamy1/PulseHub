// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_notifications_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetNotificationResponseModel _$GetNotificationResponseModelFromJson(
        Map<String, dynamic> json) =>
    GetNotificationResponseModel(
      success: json['success'] as bool?,
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetNotificationResponseModelToJson(
        GetNotificationResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'notifications': instance.notifications,
    };

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      title: json['title'] as String?,
      warnings: (json['warnings'] as List<dynamic>?)
          ?.map((e) => Warning.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'title': instance.title,
      'warnings': instance.warnings,
    };

Warning _$WarningFromJson(Map<String, dynamic> json) => Warning(
      sensorId: (json['sensor_id'] as num?)?.toInt(),
      ticketsDetails: (json['tickets_details'] as List<dynamic>?)
          ?.map((e) => TicketsDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WarningToJson(Warning instance) => <String, dynamic>{
      'sensor_id': instance.sensorId,
      'tickets_details': instance.ticketsDetails,
    };

TicketsDetail _$TicketsDetailFromJson(Map<String, dynamic> json) =>
    TicketsDetail(
      ticketName: json['ticket_name'] as String?,
      ticketDescription: json['ticket_description'] as String?,
      unseenMessages: (json['unseen_messages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TicketsDetailToJson(TicketsDetail instance) =>
    <String, dynamic>{
      'ticket_name': instance.ticketName,
      'ticket_description': instance.ticketDescription,
      'unseen_messages': instance.unseenMessages,
    };
