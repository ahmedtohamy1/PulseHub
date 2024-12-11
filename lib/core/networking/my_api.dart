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

    // Add the AppIntercepters to the Dio instance
    dio.interceptors.add(AppIntercepters());
  }

  // POST Request Method
  Future<Response> post(String endpoint,
      {required dynamic data, // Accept either FormData or Map
      String? token,
      Map<String, dynamic>? queryParameters}) async {
    try {
      // Check if data is already FormData; if not, convert it
      final requestData = data is FormData ? data : FormData.fromMap(data);

      // Create the headers for the request
      final headers = <String, String>{
        'Content-Type': 'application/json', // Always application/json
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token'; // Add token if available
      }

      // Perform the POST request
      var response = await dio.post(
        endpoint,
        data: requestData, // Use the appropriate data
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response;
    } on DioException catch (e) {
      throw Exception('DioError: Failed to make POST request: ${e.message}');
    }
  }

  // GET Request Method
  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters, String? token}) async {
    try {
      // Create the headers for the request
      final headers = <String, String>{
        'Content-Type': 'application/json', // Always application/json
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token'; // Add token if available
      }

      // Perform the GET request
      var response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response;
    } on DioException catch (e) {
      throw Exception('DioError: Failed to make GET request: ${e.message}');
    }
  }

  // DELETE Request Method
  Future<Response> delete(String endpoint,
      {Map<String, dynamic>? queryParameters, String? token}) async {
    try {
      // Create the headers for the request
      final headers = <String, String>{
        'Content-Type': 'application/json', // Always application/json
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token'; // Add token if available
      }

      // Perform the DELETE request
      var response = await dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response;
    } on DioException catch (e) {
      throw Exception('DioError: Failed to make DELETE request: ${e.message}');
    }
  }
}
