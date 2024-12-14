import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';

abstract class ProjectsRepository {
  Future<Either<String, GetProjectsResponse>> getProjects(String token);
  Future<Either<String, void>> flagOrUnflagProject({
    required String token,
    required int userId,
    required int projectId,
    required bool isFlag,
  });
}
