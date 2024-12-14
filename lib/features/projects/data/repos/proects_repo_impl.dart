import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/data/repos/projects_repo.dart';
@LazySingleton(as: ProjectsRepository)
class ProjectsRepoImpl extends ProjectsRepository {
  final MyApi myApiService;

  ProjectsRepoImpl(this.myApiService);

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
