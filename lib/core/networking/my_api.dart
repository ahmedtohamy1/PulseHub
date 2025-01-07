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
  final Dio dio;

  /// Constructs a new instance of [MyApi].
  ///
  /// The [dio] parameter is an instance of the Dio client, which is used to
  /// perform HTTP requests. The Dio instance is configured with a base URL,
  /// default headers, and interceptors during initialization.
  MyApi(this.dio) {
    // Configure Dio with default options
    dio.options.baseUrl = EndPoints.apiUrl;
    dio.options.headers['Content-Type'] = 'application/json';

    // Add the AppInterceptors to the Dio instance
    dio.interceptors.add(AppIntercepters());
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
    dynamic data, // Accept either Map, FormData, or raw data
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
          : data is FormData // Check if data is already FormData
              ? data // Use the existing FormData
              : encodeAsJson
                  ? data // Use raw data for JSON encoding
                  : FormData.fromMap(data); // Convert to FormData if it's a Map

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

  /// Sends a GET request to the specified [endpoint].
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
  /// final response = await myApi.get(
  ///   '/endpoint',
  ///   queryParameters: {'key': 'value'},
  ///   token: 'auth_token',
  /// );
  /// ```
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
    dynamic data, // Accept either Map, FormData, or raw data
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
          : data is FormData // Check if data is already FormData
              ? data // Use the existing FormData
              : encodeAsJson
                  ? data // Use raw data for JSON encoding
                  : FormData.fromMap(data); // Convert to FormData if it's a Map

      final response = await dio.put(
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
    dynamic data, // Accept either Map, FormData, or raw data
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
          : data is FormData // Check if data is already FormData
              ? data // Use the existing FormData
              : encodeAsJson
                  ? data // Use raw data for JSON encoding
                  : FormData.fromMap(data); // Convert to FormData if it's a Map

      final response = await dio.patch(
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
