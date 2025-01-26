import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/dics/data/models/dic_services_model.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/get_all_users_log_response.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/get_user_projects.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/update_dic_request_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

import 'manage_users_repo.dart';

@Injectable(as: ManageUsersRepository)
class ManageUsersRepositoryImpl implements ManageUsersRepository {
  final MyApi myApiService;

  ManageUsersRepositoryImpl(this.myApiService);

  @override
  Future<Either<String, GetAllResponseModel>> getAllUsers(String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.getAllUsers,
        token: token,
      );
      if (response.statusCode == StatusCode.ok &&
          response.data['results']['success']) {
        return Right(GetAllResponseModel.fromJson(response.data));
      } else {
        return Left('Failed to get all users: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Exception occurred: $e');
    }
  }

  @override
  Future<Either<String, bool>> deleteUser(String token, String userId) async {
    try {
      final response = await myApiService.delete(
        '${EndPoints.getAllUsers}/$userId/',
        token: token,
      );
      if (response.statusCode == StatusCode.ok && response.data['success']) {
        return Right(true);
      } else {
        return Left('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Exception occurred: $e');
    }
  }

  @override
  Future<Either<String, bool>> updateUser(
    String token,
    String userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? title,
    int? maxActiveSessions,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    XFile? picture,
  ) async {
    try {
      final Map<String, dynamic> requestData = {};

      // Add optional fields only if they are not null
      if (firstName != null && firstName.isNotEmpty) {
        requestData['first_name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        requestData['last_name'] = lastName;
      }
      if (email != null && email.isNotEmpty) {
        requestData['email'] = email;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        requestData['phone_number'] = phoneNumber;
      }
      if (title != null && title.isNotEmpty) {
        requestData['title'] = title;
      }
      if (maxActiveSessions != null) {
        requestData['max_active_sessions'] = maxActiveSessions;
      }
      if (isActive != null) {
        requestData['is_active'] = isActive;
      }
      if (isStaff != null) {
        requestData['is_staff'] = isStaff;
      }
      if (isSuperuser != null) {
        requestData['is_superuser'] = isSuperuser;
      }

      dynamic data;
      // If picture is provided, create FormData
      if (picture != null) {
        data = FormData.fromMap({
          ...requestData,
          'picture': await MultipartFile.fromFile(picture.path),
        });
      } else {
        // If no picture, just use the regular data
        data = requestData;
      }

      // if no data to update, return error
      if (requestData.isEmpty && picture == null) {
        return Left('No data to update');
      }

      final response = await myApiService.post(
        '${EndPoints.getAllUsers}/$userId/',
        token: token,
        data: data,
      );

      if (response.statusCode == StatusCode.ok && response.data['success']) {
        return Right(true);
      } else {
        return Left('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Exception occurred: $e');
    }
  }

  @override
  Future<Either<String, GetUsersProjects>> getUserProjects(
      String token, int userId) async {
    try {
      final response = await myApiService
          .post(EndPoints.getUserProjects, token: token, queryParameters: {
        'id': userId,
      }, data: <String, dynamic>{});
      if (response.statusCode == StatusCode.ok && response.data['success']) {
        return Right(GetUsersProjects.fromJson(response.data));
      } else {
        return Left('Failed to get user projects: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Exception occurred: $e');
    }
  }

  @override
  Future<Either<String, DicServicesResponse>> getDics(
      String token, String userId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getDics,
        token: token,
        queryParameters: {
          'user_id': int.parse(userId),
        },
      );

      if ((response.statusCode == StatusCode.created ||
          (response.statusCode == StatusCode.ok &&
              response.data['success'] == true))) {
        final json = response.data;
        return Right(DicServicesResponse.fromJson(json));
      } else {
        final detail = response.data['detail']?.toString() ?? '';
        if (detail.contains('Given token not valid for any token type')) {
          return const Left('Token expired');
        } else {
          return Left('Failed to get sessions: ${response.statusCode}');
        }
      }
    } on DioException catch (dioError) {
      final response = dioError.response;
      if (response != null) {
        final detail = response.data['detail']?.toString() ?? '';
        if (detail.contains('Given token not valid for any token type')) {
          return const Left('Token expired');
        } else {
          return Left(
              'Failed with status code: ${response.statusCode}, message: ${response.data}');
        }
      }
      return Left('Network error occurred: ${dioError.message}');
    } catch (error) {
      return Left('Unexpected exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> updateDics(
      String token, UpdateDicRequestModel dicServices) async {
    try {
      // Create a copy of the JSON map and remove null values
      final dicServicesWithoutNulls =
          Map<String, dynamic>.from(dicServices.toJson())
            ..removeWhere((key, value) => value == null);

      final response = await myApiService.post(
        EndPoints.getDics,
        token: token,
        data: dicServicesWithoutNulls,
      );

      // Check if the response is successful
      if (response.statusCode == StatusCode.ok) {
        final responseData = response.data;
        if (responseData != null && responseData['success'] == true) {
          return Right(true);
        } else {
          return Left('Failed to update dic services: Success flag is false');
        }
      } else {
        return Left('Failed to update dic services: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Exception occurred: $e');
    }
  }

  @override
  Future<Either<String, int>> createUser(
      String token,
      String password,
      String confirmPassword,
      String? firstName,
      String? lastName,
      String email,
      String? phoneNumber,
      String? title,
      int? maxActiveSessions,
      bool? isActive,
      bool? isStaff,
      bool? isSuperuser,
      XFile? picture) async {
    try {
      final Map<String, dynamic> requestData = {
        'password': password,
        'confirm_password': confirmPassword,
        'email': email,
      };

      if (firstName != null && firstName.isNotEmpty) {
        requestData['first_name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        requestData['last_name'] = lastName;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        requestData['phone_number'] = phoneNumber;
      }
      if (title != null && title.isNotEmpty) {
        requestData['title'] = title;
      }
      if (maxActiveSessions != null) {
        requestData['max_active_sessions'] = maxActiveSessions;
      }
      if (isActive != null) {
        requestData['is_active'] = isActive;
      }
      if (isStaff != null) {
        requestData['is_staff'] = isStaff;
      }
      if (isSuperuser != null) {
        requestData['is_superuser'] = isSuperuser;
      }
      if (picture != null) {
        requestData['picture'] = await MultipartFile.fromFile(
          picture.path,
          filename: picture.name,
        );
      }

      final response = await myApiService.post(
        EndPoints.getAllUsers,
        token: token,
        data: requestData,
      );

      // Debug log

      if (response.statusCode == StatusCode.ok && response.data['success']) {
        // Extract the user ID from the response
        // The user details are under User_Details in the response
        final userData = response.data['User_Details'];
        // Debug log

        if (userData == null) {
          // Debug log
          return const Left('Failed to get user data from response');
        }
        final userId = userData['user_id'];
        // Debug log

        if (userId == null) {
          return const Left('Failed to get user ID from response');
        }
        return Right(userId is int ? userId : int.parse(userId.toString()));
      } else {
        final errorMessage = response.data['message'] ??
            response.data['error'] ??
            'Failed to create user: ${response.statusCode}';
        // Debug log
        return Left(errorMessage.toString());
      }
    } catch (e) {
      return Left('Exception occurred: $e');
    }
  }

  @override
  Future<Either<String, GetAllUserLogResponse>> getAllUserLog(
      String token) async {
    try {
      final response =
          await myApiService.get(EndPoints.getAllUserLog, token: token);

      if (response.statusCode == StatusCode.ok) {
        try {
          final parsedResponse = GetAllUserLogResponse.fromJson(response.data);
          return Right(parsedResponse);
        } catch (parseError) {
          return Left('Failed to parse response: $parseError');
        }
      } else {
        return Left('Failed to get all user log: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Exception occurred: $e');
    }
  }
}
