import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_monitorings/data/manage_monitroings_repo.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';

@Injectable(as: ManageMonitoringsRepo)
class ManageMonitoringsRepoImpl extends ManageMonitoringsRepo {
  final MyApi myApiService;
  ManageMonitoringsRepoImpl(this.myApiService);
  @override
  Future<Either<String, MonitoringResponse>> getMonitoring(
    String token,
  ) async {
    try {
      final response = await myApiService.get(
        EndPoints.getMonitoring,
        token: token,
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(MonitoringResponse.fromJson(response.data));
      } else {
        return Left('Failed to get monitoring: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> editMonitoring(
      String token,
      String? communications,
      String? name,
      int? projectId,
      int monitoringId) async {
    try {

final Map<String, dynamic> data = {
        
      };

      if (communications != null) {
        data["communications"] = communications;
      }
      if (name != null) {
        data["name"] = name;
      }
      if (projectId != null) {
        data["project"] = projectId;
      }



      final response = await myApiService.post(
        EndPoints.getMonitoring,
        token: token,
        queryParameters: {
          'id': monitoringId,
        },
        data: data,
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(true);
      } else {
        return Left('Failed to get monitoring: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> createMonitoring(
      String token, String? communications, String name, int projectId) async {
    try {
      final Map<String, dynamic> data = {
        "name": name,
        "project": projectId,
      };

      if (communications != null) {
        data["communications"] = communications;
      }

      final response = await myApiService.post(
        EndPoints.getMonitoring,
        token: token,
        data: data,
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(true);
      } else {
        return Left('Failed to get monitoring: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> deleteMonitoring(
      String token, int monitoringId) async {
    try {
      final response = await myApiService.delete(
        EndPoints.getMonitoring,
        token: token,
        queryParameters: {
          'id': monitoringId,
        },
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(true);
      } else {
        return Left('Failed to delete monitoring: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
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
}
