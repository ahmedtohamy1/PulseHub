import 'package:json_annotation/json_annotation.dart';

part 'manage_session_response.g.dart';

@JsonSerializable()
class ManageSessionResponse {
    @JsonKey(name: "success")
    bool success;
    @JsonKey(name: "current_active_session")
    ActiveSession currentActiveSession;
    @JsonKey(name: "other_active_sessions")
    List<ActiveSession> otherActiveSessions;

    ManageSessionResponse({
        required this.success,
        required this.currentActiveSession,
        required this.otherActiveSessions,
    });

    ManageSessionResponse copyWith({
        bool? success,
        ActiveSession? currentActiveSession,
        List<ActiveSession>? otherActiveSessions,
    }) => 
        ManageSessionResponse(
            success: success ?? this.success,
            currentActiveSession: currentActiveSession ?? this.currentActiveSession,
            otherActiveSessions: otherActiveSessions ?? this.otherActiveSessions,
        );

    factory ManageSessionResponse.fromJson(Map<String, dynamic> json) => _$ManageSessionResponseFromJson(json);

    Map<String, dynamic> toJson() => _$ManageSessionResponseToJson(this);
}

@JsonSerializable()
class ActiveSession {
    @JsonKey(name: "user_activate_session_id")
    int userActivateSessionId;
    @JsonKey(name: "device_info")
    DeviceInfo deviceInfo;
    @JsonKey(name: "session_expire")
    DateTime sessionExpire;
    @JsonKey(name: "location")
    Location location;
    @JsonKey(name: "ip_address")
    String ipAddress;
    @JsonKey(name: "session_start")
    DateTime sessionStart;

    ActiveSession({
        required this.userActivateSessionId,
        required this.deviceInfo,
        required this.sessionExpire,
        required this.location,
        required this.ipAddress,
        required this.sessionStart,
    });

    ActiveSession copyWith({
        int? userActivateSessionId,
        DeviceInfo? deviceInfo,
        DateTime? sessionExpire,
        Location? location,
        String? ipAddress,
        DateTime? sessionStart,
    }) => 
        ActiveSession(
            userActivateSessionId: userActivateSessionId ?? this.userActivateSessionId,
            deviceInfo: deviceInfo ?? this.deviceInfo,
            sessionExpire: sessionExpire ?? this.sessionExpire,
            location: location ?? this.location,
            ipAddress: ipAddress ?? this.ipAddress,
            sessionStart: sessionStart ?? this.sessionStart,
        );

    factory ActiveSession.fromJson(Map<String, dynamic> json) => _$ActiveSessionFromJson(json);

    Map<String, dynamic> toJson() => _$ActiveSessionToJson(this);
}

@JsonSerializable()
class DeviceInfo {
    @JsonKey(name: "Device")
    String? device;
    @JsonKey(name: "Device Type")
    String deviceType;
    @JsonKey(name: "Browser")
    String browser;

    DeviceInfo({
        required this.device,
        required this.deviceType,
        required this.browser,
    });

    DeviceInfo copyWith({
        String? device,
        String? deviceType,
        String? browser,
    }) => 
        DeviceInfo(
            device: device ?? this.device,
            deviceType: deviceType ?? this.deviceType,
            browser: browser ?? this.browser,
        );

    factory DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);

    Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);
}

@JsonSerializable()
class Location {
    @JsonKey(name: "status")
    String status;
    @JsonKey(name: "message")
    String message;
    @JsonKey(name: "query")
    String query;

    Location({
        required this.status,
        required this.message,
        required this.query,
    });

    Location copyWith({
        String? status,
        String? message,
        String? query,
    }) => 
        Location(
            status: status ?? this.status,
            message: message ?? this.message,
            query: query ?? this.query,
        );

    factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

    Map<String, dynamic> toJson() => _$LocationToJson(this);
}
