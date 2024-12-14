import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart'
    as pr;

abstract class ProjectsRepository {
  Future<Either<String, GetProjectsResponse>> getProjects(String token);

  Future<Either<String, void>> flagOrUnflagProject({
    required String token,
    required int userId,
    required int projectId,
    required bool isFlag,
  });
  Future<Either<String, pr.Project>> getProject({
    required String token,
    required int projectId,
  });
  Future<Either<String, String>> updateOrder({
    required String token,
    required List<String> ownersOrder,
  });
}
