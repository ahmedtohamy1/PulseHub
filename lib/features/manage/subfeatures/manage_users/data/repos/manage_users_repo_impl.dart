import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

import 'manage_users_repo.dart';

@Injectable(as: ManageUsersRepository)
class ManageUsersRepositoryImpl implements ManageUsersRepository {
  final MyApi myApiService;

  ManageUsersRepositoryImpl(this.myApiService);

  @override
  Future<Either<String, GetAllResponseModel>> getAllUsers(String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.getAllUsers,
        token: token,
      );
      if (response.statusCode == StatusCode.ok && response.data['success']) {
        return Right(GetAllResponseModel.fromJson(response.data));
      } else {
        return Left('Failed to get all users: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Exception occurred: $e');
    }
  }
}
