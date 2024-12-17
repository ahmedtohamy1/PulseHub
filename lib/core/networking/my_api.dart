import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/app_interceptors.dart';
import 'package:pulsehub/core/networking/end_points.dart';

@LazySingleton()
class MyApi {
  final Dio dio;

  MyApi(this.dio) {
    // Configure Dio with default options
    dio.options.baseUrl = EndPoints.apiUrl;
    dio.options.headers['Content-Type'] = 'application/json';

    // Add the AppInterceptors to the Dio instance
    dio.interceptors.add(AppIntercepters());
  }

  // POST Request Method
  Future<Response> post(
    String endpoint, {
    dynamic data, // Accept either Map or raw data
    String? token,
    Map<String, dynamic>? queryParameters,
    bool noBody = false,
    bool encodeAsJson = false, // Flag for JSON encoding
  }) async {
    try {
      // Generate request headers
      final headers = _generateHeaders(token);

      // Handle requests with no body
      final requestData = noBody
          ? null
          : encodeAsJson
              ? data // Use raw data for JSON encoding
              : FormData.fromMap(data); // Convert to FormData

      final response = await dio.post(
        endpoint,
        data: requestData,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          contentType: encodeAsJson
              ? Headers.jsonContentType
              : Headers.formUrlEncodedContentType,
        ),
      );

      return response;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow; // Let the caller handle the exception if necessary
    }
  }

  // GET Request Method
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      final headers = _generateHeaders(token);

      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow; // Let the caller handle the exception if necessary
    }
  }

  // DELETE Request Method
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      final headers = _generateHeaders(token);

      final response = await dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow; // Let the caller handle the exception if necessary
    }
  }

  // Generate headers for requests
  Map<String, String> _generateHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Handle Dio-specific exceptions
  void _handleDioException(DioException e) {
    if (e.response != null) {
      if (e.response?.statusCode == 401) {
        final detail = e.response?.data['detail']?.toString() ?? '';
        throw Exception(detail);
      }
    }
    throw Exception('DioError: Failed to make request: ${e.message}');
  }
}
