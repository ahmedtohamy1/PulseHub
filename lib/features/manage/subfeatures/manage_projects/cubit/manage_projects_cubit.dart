import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/get_all_projects_response_model.dart';

import '../data/repos/manage_projects_repo.dart';

part 'manage_projects_state.dart';

@injectable
class ManageProjectsCubit extends Cubit<ManageProjectsState> {
  final ManageProjectsRepository _repository;
  ManageProjectsCubit(this._repository) : super(ManageProjectsInitial());

  Future<void> getAllProjects() async {
    emit(GetAllProjectsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repository.getAllProjects(token);
    result.fold((l) => emit(GetAllProjectsFailure(l)),
        (r) => emit(GetAllProjectsSuccess(r)));
  }
}
