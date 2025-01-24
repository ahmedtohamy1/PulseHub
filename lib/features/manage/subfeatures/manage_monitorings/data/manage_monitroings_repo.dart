import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';

abstract class ManageMonitoringsRepo {
  Future<Either<String, MonitoringResponse>> getMonitoring(String token);
  Future<Either<String, bool>> editMonitoring(String token,
      String? communications, String? name, int? projectId, int monitoringId);

  Future<Either<String, GetProjectsResponse>> getProjects(String token);
}
