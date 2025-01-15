import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

abstract class ManageUsersRepository {

   Future<Either<String, GetAllResponseModel>> getAllUsers(String token);
}
