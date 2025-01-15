import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

abstract class ManageUsersRepository {
  Future<Either<String, GetAllResponseModel>> getAllUsers(String token);
  Future<Either<String, bool>> deleteUser(String token, String userId);
  Future<Either<String, bool>> updateUser(
    String token,
    String userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? title,
    int? maxActiveSessions,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    XFile? picture,
  );
}
