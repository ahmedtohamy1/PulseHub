import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_monitorings/data/manage_monitroings_repo.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';

part 'manage_monitorings_state.dart';

@Injectable()
class ManageMonitoringsCubit extends Cubit<ManageMonitoringsState> {
  final ManageMonitoringsRepo _repo;
  MonitoringResponse? _cachedMonitorings;
  GetProjectsResponse? _cachedProjects;

  ManageMonitoringsCubit(this._repo) : super(ManageMonitoringsInitial());

  Future<void> getMonitorings() async {
    // Always emit cached data first if available
    if (_cachedMonitorings != null) {
      emit(ManageMonitoringsSuccess(_cachedMonitorings!,
          projectsResponse: _cachedProjects));
    } else {
      emit(ManageMonitoringsLoading(projectsResponse: _cachedProjects));
    }

    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repo.getMonitoring(token);
    result.fold(
      (l) => emit(ManageMonitoringsFailure(l,
          monitoringResponse: _cachedMonitorings,
          projectsResponse: _cachedProjects)),
      (r) {
        _cachedMonitorings = r;
        emit(ManageMonitoringsSuccess(r, projectsResponse: _cachedProjects));
      },
    );
  }

  Future<void> editMonitoring(String? communications, String? name,
      int? projectId, int monitoringId) async {
    emit(ManageMonitoringsEditLoading(
      monitoringResponse: _cachedMonitorings,
      projectsResponse: _cachedProjects,
    ));
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repo.editMonitoring(
        token, communications, name, projectId, monitoringId);
    result.fold(
      (l) => emit(ManageMonitoringsEditFailure(l,
          monitoringResponse: _cachedMonitorings,
          projectsResponse: _cachedProjects)),
      (r) {
        // Update the cached monitoring if edit was successful
        if (_cachedMonitorings != null &&
            _cachedMonitorings!.monitorings != null) {
          final updatedMonitorings =
              _cachedMonitorings!.monitorings!.map((monitoring) {
            if (monitoring.monitoringId == monitoringId) {
              return Monitoring(
                monitoringId: monitoringId,
                name: name ?? monitoring.name,
                project: projectId ?? monitoring.project,
                communications: communications ?? monitoring.communications,
                usedSensors: monitoring.usedSensors,
              );
            }
            return monitoring;
          }).toList();

          _cachedMonitorings = MonitoringResponse(
            success: true,
            monitorings: updatedMonitorings,
          );
        }
        emit(ManageMonitoringsEditSuccess(r,
            monitoringResponse: _cachedMonitorings,
            projectsResponse: _cachedProjects));
      },
    );
  }

  Future<void> getProjects() async {
    // Always emit cached projects first if available
    if (_cachedProjects != null) {
      emit(ManageMonitoringsGetProjectsSuccess(_cachedProjects!,
          monitoringResponse: _cachedMonitorings));
    } else {
      emit(ManageMonitoringsGetProjectsLoading(
          monitoringResponse: _cachedMonitorings));
    }

    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repo.getProjects(token);
    result.fold(
      (l) => emit(ManageMonitoringsGetProjectsFailure(l,
          monitoringResponse: _cachedMonitorings,
          projectsResponse: _cachedProjects)),
      (r) {
        _cachedProjects = r;
        emit(ManageMonitoringsGetProjectsSuccess(r,
            monitoringResponse: _cachedMonitorings));
      },
    );
  }

  void clearCache() {
    _cachedMonitorings = null;
    _cachedProjects = null;
  }

  @override
  Future<void> close() {
    clearCache();
    return super.close();
  }
}
