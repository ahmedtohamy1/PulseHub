import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/project_dashboard/data/models/cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo_impl.dart';

abstract class DashRepository {
  Future<Either<String, ProjectDashboards>> getDashs(
      String token, int projectId);
  Future<Either<String, CloudHubResponse>> getDashDetails(
      String org, int projectId, String token);
  Future<Either<String, SensorDataResponse>> getTimeDb(
      String token, QueryParams queryParams);

  Future<Either<String, bool>> createDash(String token, String name,
      String description, String group, int projectId);
}
