import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/get_user_projects.dart';
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
      if (response.statusCode == StatusCode.ok && response.data['success']) {
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
}
