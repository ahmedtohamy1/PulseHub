import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
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
}
