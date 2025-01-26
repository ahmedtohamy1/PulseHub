import 'package:json_annotation/json_annotation.dart';

part 'get_all_users_log_response.g.dart';

@JsonSerializable()
class GetAllUserLogResponse {
  @JsonKey(name: "count")
  final int count;
  @JsonKey(name: "next")
  final String? next;
  @JsonKey(name: "previous")
  final String? previous;
  @JsonKey(name: "results")
  final Results results;

  const GetAllUserLogResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory GetAllUserLogResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAllUserLogResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllUserLogResponseToJson(this);
}

@JsonSerializable()
class Results {
  @JsonKey(name: "success", defaultValue: true)
  final bool success;
  @JsonKey(name: "logs")
  final List<Log> logs;

  const Results({
    required this.success,
    required this.logs,
  });

  factory Results.fromJson(Map<String, dynamic> json) =>
      _$ResultsFromJson(json);

  Map<String, dynamic> toJson() => _$ResultsToJson(this);
}

@JsonSerializable()
class Log {
  @JsonKey(name: "user_log_id")
  final int userLogId;
  @JsonKey(name: "user")
  final int user;
  @JsonKey(name: "path")
  final String path;
  @JsonKey(name: "method")
  final String method;
  @JsonKey(name: "timestamp")
  final DateTime timestamp;
  @JsonKey(name: "ip_address")
  final String ipAddress;
  @JsonKey(name: "user_agent")
  final String userAgent;
  @JsonKey(name: "request_headers")
  final String requestHeaders;
  @JsonKey(name: "request_cookies")
  final String requestCookies;
  @JsonKey(name: "request_query_params")
  final String requestQueryParams;
  @JsonKey(name: "request_data")
  final String requestData;
  @JsonKey(name: "status_code")
  final int statusCode;
  @JsonKey(name: "response_data")
  final String responseData;

  const Log({
    required this.userLogId,
    required this.user,
    required this.path,
    required this.method,
    required this.timestamp,
    required this.ipAddress,
    required this.userAgent,
    required this.requestHeaders,
    required this.requestCookies,
    required this.requestQueryParams,
    required this.requestData,
    required this.statusCode,
    required this.responseData,
  });

  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);

  Map<String, dynamic> toJson() => _$LogToJson(this);
}
