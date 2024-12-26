import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/project_dashboard/data/models/cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo_impl.dart';

part 'project_dashboard_state.dart';

@injectable
class ProjectDashboardCubit extends Cubit<ProjectDashboardState> {
  final DashRepository _repository;

  ProjectDashboardCubit(this._repository) : super(ProjectDashboardInitial());

  getDashs(int projectId) async {
    emit(ProjectDashboardFetchLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getDashs(token, projectId);
    res.fold(
      (failure) => emit(ProjectDashboardFetchFailure(failure)),
      (response) => emit(ProjectDashboardFetchSuccess(response)),
    );
  }

  getDashDetails(int projectId) async {
    emit(ProjectDashboardDetailsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getDashDetails('DIC', projectId, token);
    res.fold(
      (failure) => emit(ProjectDashboardDetailsFailure(failure)),
      (response) => emit(ProjectDashboardDetailsSuccess(response)),
    );
  }

  getTimeDb(QueryParams queryParams) async {
    emit(ProjectDashboardDetailsTimeDbLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getTimeDb(token, queryParams);
    res.fold(
      (failure) => emit(ProjectDashboardDetailsTimeDbFailure(failure)),
      (response) => emit(ProjectDashboardDetailsTimeDbSuccess(response)),
    );
  }
}
