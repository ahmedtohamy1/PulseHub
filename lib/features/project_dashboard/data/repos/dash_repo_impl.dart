import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';

import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo.dart';

@LazySingleton(as: DashRepository)
class DashRepoImpl extends DashRepository {
  final MyApi myApiService;

  DashRepoImpl(this.myApiService);
  @override
  Future<Either<String, ProjectDashboards>> getDashs(
      String token, int projectId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getDashs,
        token: token,
        queryParameters: {'project_id': projectId},
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        final json = response.data;

        return Right(ProjectDashboards.fromJson(json));
      } else {
        return Left('Failed to get Dashs: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }
}
