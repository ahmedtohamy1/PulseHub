import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/dics/data/models/dic_services_model.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/get_user_projects.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/models/update_dic_request_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';

import '../data/repos/manage_users_repo.dart';

part 'manage_users_state.dart';

@injectable
class ManageUsersCubit extends Cubit<ManageUsersState> {
  final ManageUsersRepository _repository;
  ManageUsersCubit(this._repository) : super(ManageUsersInitial());

  Future<void> getAllUsers() async {
    emit(ManageUsersLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final response = await _repository.getAllUsers(token);
    response.fold(
      (l) => emit(ManageUsersFailure(l)),
      (r) => emit(ManageUsersSuccess(r)),
    );
  }

  Future<void> deleteUser(String userId) async {
    emit(ManageUsersDeleteLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final response = await _repository.deleteUser(token, userId);
    response.fold(
      (l) => emit(ManageUsersDeleteFailure(l)),
      (r) {
        emit(ManageUsersDeleteSuccess(r));
        getAllUsers();
      },
    );
  }

  Future<void> updateUser(
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
      XFile? picture) async {
    emit(ManageUsersUpdateLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final response = await _repository.updateUser(
        token,
        userId,
        firstName,
        lastName,
        email,
        phoneNumber,
        title,
        maxActiveSessions,
        isActive,
        isStaff,
        isSuperuser,
        picture);
    response.fold(
      (l) => emit(ManageUsersUpdateFailure(l)),
      (r) {
        emit(ManageUsersUpdateSuccess(r));
        getAllUsers();
      },
    );
  }

  Future<void> getUserProjects(int userId) async {
    emit(ManageUsersGetUserProjectsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final response = await _repository.getUserProjects(token, userId);
    response.fold(
      (l) => emit(ManageUsersGetUserProjectsFailure(l)),
      (r) => emit(ManageUsersGetUserProjectsSuccess(r)),
    );
  }

  Future<void> getDics(String userId) async {
    emit(ManageUsersGetDicsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final response = await _repository.getDics(token, userId);
    response.fold(
      (l) => emit(ManageUsersGetDicsFailure(l)),
      (r) => emit(ManageUsersGetDicsSuccess(r)),
    );
  }

  Future<void> updateDics(UpdateDicRequestModel dicServices) async {
    emit(ManageUsersUpdateDicsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final response = await _repository.updateDics(token, dicServices);
    response.fold(
      (l) => emit(ManageUsersUpdateDicsFailure(l)),
      (r) => emit(ManageUsersUpdateDicsSuccess(r)),
    );
  }
}
