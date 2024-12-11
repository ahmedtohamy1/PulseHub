import 'package:json_annotation/json_annotation.dart';

part 'manage_session_response.g.dart';

@JsonSerializable()
class ManageSessionResponse {
  final bool success;
  final Session? currentActiveSession;
  final List<Session> otherActiveSessions;

  ManageSessionResponse({
    required this.success,
    this.currentActiveSession,
    required this.otherActiveSessions,
  });

  factory ManageSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$ManageSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ManageSessionResponseToJson(this);
}

@JsonSerializable()
class Session {
  final int userActivateSessionId;
  final DeviceInfo deviceInfo;
  final String sessionExpire;
  final Location location;
  final String ipAddress;
  final String sessionStart;

  Session({
    required this.userActivateSessionId,
    required this.deviceInfo,
    required this.sessionExpire,
    required this.location,
    required this.ipAddress,
    required this.sessionStart,
  });

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);
}

@JsonSerializable()
class DeviceInfo {
  final String device;
  final String deviceType;
  final String browser;

  DeviceInfo({
    required this.device,
    required this.deviceType,
    required this.browser,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);
}

@JsonSerializable()
class Location {
  final String status;
  final String message;
  final String query;

  Location({
    required this.status,
    required this.message,
    required this.query,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
