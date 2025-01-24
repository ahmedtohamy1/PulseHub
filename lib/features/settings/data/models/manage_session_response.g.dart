// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManageSessionResponse _$ManageSessionResponseFromJson(
        Map<String, dynamic> json) =>
    ManageSessionResponse(
      success: json['success'] as bool,
      currentActiveSession: ActiveSession.fromJson(
          json['current_active_session'] as Map<String, dynamic>),
      otherActiveSessions: (json['other_active_sessions'] as List<dynamic>)
          .map((e) => ActiveSession.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ManageSessionResponseToJson(
        ManageSessionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'current_active_session': instance.currentActiveSession,
      'other_active_sessions': instance.otherActiveSessions,
    };

ActiveSession _$ActiveSessionFromJson(Map<String, dynamic> json) =>
    ActiveSession(
      userActivateSessionId: (json['user_activate_session_id'] as num).toInt(),
      deviceInfo:
          DeviceInfo.fromJson(json['device_info'] as Map<String, dynamic>),
      sessionExpire: DateTime.parse(json['session_expire'] as String),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      ipAddress: json['ip_address'] as String,
      sessionStart: DateTime.parse(json['session_start'] as String),
    );

Map<String, dynamic> _$ActiveSessionToJson(ActiveSession instance) =>
    <String, dynamic>{
      'user_activate_session_id': instance.userActivateSessionId,
      'device_info': instance.deviceInfo,
      'session_expire': instance.sessionExpire.toIso8601String(),
      'location': instance.location,
      'ip_address': instance.ipAddress,
      'session_start': instance.sessionStart.toIso8601String(),
    };

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => DeviceInfo(
      device: json['Device'] as String?,
      deviceType: json['Device Type'] as String,
      browser: json['Browser'] as String,
    );

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'Device': instance.device,
      'Device Type': instance.deviceType,
      'Browser': instance.browser,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      status: json['status'] as String,
      message: json['message'] as String,
      query: json['query'] as String,
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'query': instance.query,
    };
