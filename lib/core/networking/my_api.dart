import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/app_interceptors.dart';
import 'package:pulsehub/core/networking/end_points.dart';

/// A service class for making HTTP requests using the Dio package.
///
/// This class provides methods for performing GET, POST, PUT, PATCH, and DELETE requests.
/// It is configured with a base URL, default headers, and interceptors for
/// handling request/response logging, error handling, and token injection.
///
/// The class is designed to be used as a singleton, injected via the `injectable`
/// package, to ensure a single instance is shared across the application.
///
/// Example usage:
/// ```dart
/// final myApi = MyApi(dio);
/// final response = await myApi.get('/endpoint');
/// ```
@LazySingleton()
class MyApi {
  final Dio _dio;

  /// Constructs a new instance of [MyApi].
  ///
  /// The [_dio] parameter is an instance of the Dio client, which is used to
  /// perform HTTP requests. The Dio instance is configured with a base URL,
  /// default headers, and interceptors during initialization.
  MyApi(this._dio) {
    // Configure Dio with default options
    _dio.options.baseUrl = EndPoints.apiUrl;
    _dio.options.headers['Content-Type'] = 'application/json';

    // Add the AppInterceptors to the Dio instance
    _dio.interceptors.add(AppIntercepters());
  }

  /// Sends a GET request to the specified [endpoint].
  ///
  /// The [queryParameters] parameter is optional and can be used to include
  /// query parameters in the request URL.
  ///
  /// The [options] parameter is optional and can be used to include additional
  /// options such as headers and withCredentials.
  ///
  /// Throws an exception if the request fails. The exception includes details
  /// about the error, such as the status code and error message.
  ///
  /// Example usage:
  /// ```dart
  /// final response = await myApi.get(
  ///   '/endpoint',
  ///   queryParameters: {'key': 'value'},
  ///   options: {'headers': {'Authorization': 'Bearer auth_token'}},
  /// );
  /// ```
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? token,
    Map<String, dynamic>? options,
  }) async {
    try {
      final headers = _generateHeaders(token);
      if (options?['headers'] != null) {
        headers.addAll(options!['headers']);
      }

      final dioOptions = Options(
        headers: headers,
        extra: {'withCredentials': options?['withCredentials'] ?? false},
      );

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: dioOptions,
      );
      return response;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  /// Sends a POST request to the specified [endpoint].
  ///
  /// The [data] parameter can be a `Map`, `FormData`, or raw data. If [noBody]
  /// is `true`, no request body will be sent. If [encodeAsJson] is `true`, the
  /// data will be sent as JSON; otherwise, it will be sent as form-encoded.
  ///
  /// The [token] parameter is optional and can be used to include an
  /// authorization token in the request headers.
  ///
  /// The [queryParameters] parameter is optional and can be used to include
  /// query parameters in the request URL.
  ///
  /// Throws an exception if the request fails. The exception includes details
  /// about the error, such as the status code and error message.
  ///
  /// Example usage:
  /// ```dart
  /// final response = await myApi.post(
  ///   '/endpoint',
  ///   data: {'key': 'value'},
  ///   token: 'auth_token',
  /// );
  /// ```
  Future<Response> post(
    String endpoint, {
    dynamic data,
    String? token,
    Map<String, dynamic>? queryParameters,
    bool noBody = false,
    bool encodeAsJson = false,
    Map<String, dynamic>? options,
  }) async {
    try {
      final headers = _generateHeaders(token);
      if (options?['headers'] != null) {
        headers.addAll(options!['headers']);
      }

      final requestData = noBody
          ? null
          : data is FormData
              ? data
              : encodeAsJson
                  ? data
                  : FormData.fromMap(data);

      final dioOptions = Options(
        headers: headers,
        contentType: encodeAsJson
            ? Headers.jsonContentType
            : Headers.formUrlEncodedContentType,
        extra: {'withCredentials': options?['withCredentials'] ?? false},
      );

      final response = await _dio.post(
        endpoint,
        data: requestData,
        queryParameters: queryParameters,
        options: dioOptions,
      );
      return response;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  /// Sends a PUT request to the specified [endpoint].
  ///
  /// The [data] parameter can be a `Map`, `FormData`, or raw data. If [noBody]
  /// is `true`, no request body will be sent. If [encodeAsJson] is `true`, the
  /// data will be sent as JSON; otherwise, it will be sent as form-encoded.
  ///
  /// The [token] parameter is optional and can be used to include an
  /// authorization token in the request headers.
  ///
  /// The [queryParameters] parameter is optional and can be used to include
  /// query parameters in the request URL.
  ///
  /// Throws an exception if the request fails. The exception includes details
  /// about the error, such as the status code and error message.
  ///
  /// Example usage:
  /// ```dart
  /// final response = await myApi.put(
  ///   '/endpoint',
  ///   data: {'key': 'value'},
  ///   token: 'auth_token',
  /// );
  /// ```
  Future<Response> put(
    String endpoint, {
    dynamic data,
    String? token,
    Map<String, dynamic>? queryParameters,
    bool noBody = false,
    bool encodeAsJson = false,
    Map<String, dynamic>? options,
  }) async {
    try {
      final headers = _generateHeaders(token);
      if (options?['headers'] != null) {
        headers.addAll(options!['headers']);
      }

      final requestData = noBody
          ? null
          : data is FormData
              ? data
              : encodeAsJson
                  ? data
                  : FormData.fromMap(data);

      final dioOptions = Options(
        headers: headers,
        contentType: encodeAsJson
            ? Headers.jsonContentType
            : Headers.formUrlEncodedContentType,
        extra: {'withCredentials': options?['withCredentials'] ?? false},
      );

      final response = await _dio.put(
        endpoint,
        data: requestData,
        queryParameters: queryParameters,
        options: dioOptions,
      );
      return response;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  /// Sends a PATCH request to the specified [endpoint].
  ///
  /// The [data] parameter can be a `Map`, `FormData`, or raw data. If [noBody]
  /// is `true`, no request body will be sent. If [encodeAsJson] is `true`, the
  /// data will be sent as JSON; otherwise, it will be sent as form-encoded.
  ///
  /// The [token] parameter is optional and can be used to include an
  /// authorization token in the request headers.
  ///
  /// The [queryParameters] parameter is optional and can be used to include
  /// query parameters in the request URL.
  ///
  /// Throws an exception if the request fails. The exception includes details
  /// about the error, such as the status code and error message.
  ///
  /// Example usage:
  /// ```dart
  /// final response = await myApi.patch(
  ///   '/endpoint',
  ///   data: {'key': 'value'},
  ///   token: 'auth_token',
  /// );
  /// ```
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    String? token,
    Map<String, dynamic>? queryParameters,
    bool noBody = false,
    bool encodeAsJson = false,
    Map<String, dynamic>? options,
  }) async {
    try {
      final headers = _generateHeaders(token);
      if (options?['headers'] != null) {
        headers.addAll(options!['headers']);
      }

      final requestData = noBody
          ? null
          : data is FormData
              ? data
              : encodeAsJson
                  ? data
                  : FormData.fromMap(data);

      final dioOptions = Options(
        headers: headers,
        contentType: encodeAsJson
            ? Headers.jsonContentType
            : Headers.formUrlEncodedContentType,
        extra: {'withCredentials': options?['withCredentials'] ?? false},
      );

      final response = await _dio.patch(
        endpoint,
        data: requestData,
        queryParameters: queryParameters,
        options: dioOptions,
      );
      return response;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  /// Sends a DELETE request to the specified [endpoint].
  ///
  /// The [queryParameters] parameter is optional and can be used to include
  /// query parameters in the request URL.
  ///
  /// The [token] parameter is optional and can be used to include an
  /// authorization token in the request headers.
  ///
  /// Throws an exception if the request fails. The exception includes details
  /// about the error, such as the status code and error message.
  ///
  /// Example usage:
  /// ```dart
  /// final response = await myApi.delete(
  ///   '/endpoint',
  ///   queryParameters: {'key': 'value'},
  ///   token: 'auth_token',
  /// );
  /// ```
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    String? token,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? options,
  }) async {
    try {
      final headers = _generateHeaders(token);
      if (options?['headers'] != null) {
        headers.addAll(options!['headers']);
      }

      final dioOptions = Options(
        headers: headers,
        extra: {'withCredentials': options?['withCredentials'] ?? false},
      );

      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: dioOptions,
      );
      return response;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  /// Generates headers for HTTP requests.
  ///
  /// The [token] parameter is optional and is used to include an authorization
  /// token in the headers. If no token is provided, the headers will only
  /// include the default `Content-Type`.
  ///
  /// Returns a `Map<String, String>` containing the request headers.
  Map<String, String> _generateHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Handles Dio-specific exceptions.
  ///
  /// This method checks the response status code and throws an exception with
  /// a descriptive message. If the status code is 401 (Unauthorized), it
  /// extracts the error detail from the response data.
  ///
  /// Throws an exception with a detailed error message.
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
