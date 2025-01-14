import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/get_all_projects_response_model.dart';

import 'manage_projects_repo.dart';

@Injectable(as: ManageProjectsRepository)
class ManageProjectsRepositoryImpl implements ManageProjectsRepository {
  final MyApi myApiService;
  ManageProjectsRepositoryImpl(this.myApiService);

  @override
  Future<Either<String, GetAllProjectsResponseModel>> getAllProjects(
      String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.getProject,
        token: token,
      );
      if (response.statusCode == StatusCode.ok) {
        return right(GetAllProjectsResponseModel.fromJson(response.data));
      } else {
        return left(response.statusCode.toString());
      }
    } catch (e) {
      return left(e.toString());
    }
  }
}
