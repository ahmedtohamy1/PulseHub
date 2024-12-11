// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManageSessionResponse _$ManageSessionResponseFromJson(
        Map<String, dynamic> json) =>
    ManageSessionResponse(
      success: json['success'] as bool,
      currentActiveSession: json['currentActiveSession'] == null
          ? null
          : Session.fromJson(
              json['currentActiveSession'] as Map<String, dynamic>),
      otherActiveSessions: (json['otherActiveSessions'] as List<dynamic>)
          .map((e) => Session.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ManageSessionResponseToJson(
        ManageSessionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'currentActiveSession': instance.currentActiveSession,
      'otherActiveSessions': instance.otherActiveSessions,
    };

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
      userActivateSessionId: (json['userActivateSessionId'] as num).toInt(),
      deviceInfo:
          DeviceInfo.fromJson(json['deviceInfo'] as Map<String, dynamic>),
      sessionExpire: json['sessionExpire'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      ipAddress: json['ipAddress'] as String,
      sessionStart: json['sessionStart'] as String,
    );

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'userActivateSessionId': instance.userActivateSessionId,
      'deviceInfo': instance.deviceInfo,
      'sessionExpire': instance.sessionExpire,
      'location': instance.location,
      'ipAddress': instance.ipAddress,
      'sessionStart': instance.sessionStart,
    };

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => DeviceInfo(
      device: json['device'] as String,
      deviceType: json['deviceType'] as String,
      browser: json['browser'] as String,
    );

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'device': instance.device,
      'deviceType': instance.deviceType,
      'browser': instance.browser,
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
