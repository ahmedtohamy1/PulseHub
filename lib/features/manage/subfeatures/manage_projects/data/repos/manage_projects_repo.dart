import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/get_all_projects_response_model.dart';

abstract class ManageProjectsRepository {
 Future<Either<String, GetAllProjectsResponseModel>>getAllProjects(String token);
}
