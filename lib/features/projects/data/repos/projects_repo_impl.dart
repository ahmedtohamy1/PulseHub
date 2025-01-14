import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/data/repos/projects_repo.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart'
    as pr;

@LazySingleton(as: ProjectsRepository)
class ProjectsRepoImpl implements ProjectsRepository {
  final MyApi myApiService;

  ProjectsRepoImpl(this.myApiService);
  @override
  Future<Either<String, void>> flagOrUnflagProject({
    required String token,
    required int userId,
    required int projectId,
    required bool isFlag,
  }) async {
    try {
      // Prepare the request body
      final requestBody = {
        "user_id": userId,
        "project_id": projectId,
        "is_flag": isFlag,
      };

      // Send POST request using the updated MyApi class
      final response = await myApiService.post(
        EndPoints.flagProject, // Endpoint URL
        data: requestBody,
        token: token,
        encodeAsJson: true,
      );

      // Handle the response
      if (response.statusCode == StatusCode.ok ||
          response.statusCode == StatusCode.created) {
        return const Right(null); // Success
      } else {
        return Left(
            'Failed to flag/unflag project: ${response.data['message']}');
      }
    } on DioException catch (dioError) {
      return Left('Network error occurred: ${dioError.message}');
    } catch (error) {
      return Left('Unexpected exception occurred: $error');
    }
  }

  @override
  Future<Either<String, GetProjectsResponse>> getProjects(String token) async {
    try {
      final response = await myApiService.post(
        noBody: true,
        EndPoints.getProjects,
        token: token,
      );

      if ((response.statusCode == StatusCode.created ||
          (response.statusCode == StatusCode.ok &&
              response.data['success'] == true))) {
        final json = response.data;

        if (json['owners'] == null) {
          return const Left('Invalid data: "owners" is null.');
        }

        return Right(GetProjectsResponse.fromJson(json));
      } else {
        return Left('Failed to get projects: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      return Left('Network error occurred: ${dioError.message}');
    } catch (error) {
      return Left('Unexpected exception occurred: $error');
    }
  }

  @override
  Future<Either<String, pr.Project>> getProject({
    required String token,
    required int projectId,
  }) async {
    try {
      final response = await myApiService.get(
        EndPoints.getProject, // Base URL
        queryParameters: {
          'id': projectId
        }, // Pass project ID as query parameter
        token: token, // Include authorization token
      );

      if (response.statusCode == StatusCode.ok &&
          response.data['success'] == true) {
        final projectJson = response.data['project'];
        if (projectJson == null) {
          return const Left('Project details not found.');
        }
        return Right(pr.Project.fromJson(projectJson)); // Map JSON to `Project`
      } else {
        return Left(
            'Failed to fetch project details: ${response.data['message']}');
      }
    } on DioException catch (dioError) {
      return Left('Network error occurred: ${dioError.message}');
    } catch (error) {
      return Left('Unexpected exception occurred: $error');
    }
  }

  @override
  Future<Either<String, String>> updateOrder({
    required String token,
    required List<int> ownersOrder,
  }) async {
    try {
      // Prepare the request body
      final requestBody = {
        "owners_order": ownersOrder,
      };

      // Send POST request
      final response = await myApiService.post(
        EndPoints.userDetails,
        data: requestBody,
        encodeAsJson: true,
        token: token,
      );

      // Handle response
      if (response.statusCode == StatusCode.ok ||
          response.statusCode == StatusCode.created) {
        return const Right('Order Updated'); // Success
      } else {
        return Left('Failed to update order: ${response.data['message']}');
      }
    } on DioException catch (dioError) {
      return Left('Network error occurred: ${dioError.message}');
    } catch (error) {
      return Left('Unexpected exception occurred: $error');
    }
  }
}
