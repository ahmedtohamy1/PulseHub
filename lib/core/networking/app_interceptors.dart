import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppIntercepters extends Interceptor {
  // ANSI color codes
  final String reset = '\x1B[0m';
  final String red = '\x1B[31m';
  final String green = '\x1B[32m';
  final String yellow = '\x1B[33m';
  final String blue = '\x1B[34m';
  final String magenta = '\x1B[35m';
  final String cyan = '\x1B[36m';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final dynamic requestBody = options.data is FormData
        ? (options.data as FormData)
            .fields
            .map((field) => '${field.key}: ${field.value}')
            .join(', ')
        : options.data;

    debugPrint('${cyan}REQUEST:$blue [${options.method}] ${options.path} '
        '${yellow}Query:$reset ${options.queryParameters} '
        '${magenta}Headers:$reset ${options.headers} '
        '${green}Body:$reset $requestBody');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        '${green}RESPONSE:$magenta [${response.statusCode}] ${response.requestOptions.path} '
        '${cyan}Headers:$reset ${response.headers.map} '
        '${yellow}Data:$reset ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
        '${red}ERROR:$yellow [${err.response?.statusCode ?? 'N/A'}] ${err.requestOptions.path} '
        '${magenta}Message:$reset ${err.message} '
        '${yellow}Response:$reset ${err.response?.data ?? 'N/A'}');

    final dynamic requestBody = err.requestOptions.data is FormData
        ? (err.requestOptions.data as FormData)
            .fields
            .map((field) => '${field.key}: ${field.value}')
            .join(', ')
        : err.requestOptions.data;

    debugPrint(
        '${cyan}REQUEST (For Error):$blue [${err.requestOptions.method}] ${err.requestOptions.path} '
        '${yellow}Query:$reset ${err.requestOptions.queryParameters} '
        '${magenta}Headers:$reset ${err.requestOptions.headers} '
        '${green}Body:$reset $requestBody');
    super.onError(err, handler);
  }
}
