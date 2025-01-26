import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/dics/data/models/dic_services_model.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/get_all_users_log_response.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/get_user_projects.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/update_dic_request_model.dart';
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
  Future<Either<String, GetUsersProjects>> getUserProjects(
      String token, int userId);

  Future<Either<String, DicServicesResponse>> getDics(
      String token, String userId);

  Future<Either<String, bool>> updateDics(
      String token, UpdateDicRequestModel dicServices);
  Future<Either<String, GetAllUserLogResponse>> getAllUserLog(String token);

  Future<Either<String, int>> createUser(
    String token,
    String password,
    String confirmPassword,
    String? firstName,
    String? lastName,
    String email,
    String? phoneNumber,
    String? title,
    int? maxActiveSessions,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    XFile? picture,
  );
}
