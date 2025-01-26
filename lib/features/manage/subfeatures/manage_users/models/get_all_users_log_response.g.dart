// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_users_log_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllUserLogResponse _$GetAllUserLogResponseFromJson(
        Map<String, dynamic> json) =>
    GetAllUserLogResponse(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: Results.fromJson(json['results'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetAllUserLogResponseToJson(
        GetAllUserLogResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };

Results _$ResultsFromJson(Map<String, dynamic> json) => Results(
      success: json['success'] as bool? ?? true,
      logs: (json['logs'] as List<dynamic>)
          .map((e) => Log.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ResultsToJson(Results instance) => <String, dynamic>{
      'success': instance.success,
      'logs': instance.logs,
    };

Log _$LogFromJson(Map<String, dynamic> json) => Log(
      userLogId: (json['user_log_id'] as num).toInt(),
      user: (json['user'] as num).toInt(),
      path: json['path'] as String,
      method: json['method'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipAddress: json['ip_address'] as String,
      userAgent: json['user_agent'] as String,
      requestHeaders: json['request_headers'] as String,
      requestCookies: json['request_cookies'] as String,
      requestQueryParams: json['request_query_params'] as String,
      requestData: json['request_data'] as String,
      statusCode: (json['status_code'] as num).toInt(),
      responseData: json['response_data'] as String,
    );

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'user_log_id': instance.userLogId,
      'user': instance.user,
      'path': instance.path,
      'method': instance.method,
      'timestamp': instance.timestamp.toIso8601String(),
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'request_headers': instance.requestHeaders,
      'request_cookies': instance.requestCookies,
      'request_query_params': instance.requestQueryParams,
      'request_data': instance.requestData,
      'status_code': instance.statusCode,
      'response_data': instance.responseData,
    };
