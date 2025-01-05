import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/project_dashboard/data/models/ai_analyze_data_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_details.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
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

  CloudHubResponse? cloudHubResponse;
  SensorDataResponse? lastTimeDbResponse;

  getDashDetails(int projectId) async {
    emit(ProjectDashboardDetailsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getDashDetails('DIC', projectId, token);

    res.fold(
      (failure) => emit(ProjectDashboardDetailsFailure(failure)),
      (response) {
        cloudHubResponse = response;
        emit(ProjectDashboardDetailsSuccess(response));
      },
    );
  }

  getTimeDb(QueryParams queryParams) async {
    emit(ProjectDashboardDetailsTimeDbLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getTimeDb(token, queryParams);
    res.fold(
      (failure) => emit(ProjectDashboardDetailsTimeDbFailure(failure)),
      (response) {
        lastTimeDbResponse = response;
        emit(ProjectDashboardDetailsTimeDbSuccess(response));
      },
    );
  }

  analyzeSensorData(QueryParams queryParams, String projectId) async {
    emit(ProjectDashboardAnalyzeSensorDataLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res =
        await _repository.analyzeSensorData(token, queryParams, projectId);
    res.fold(
      (failure) => emit(ProjectDashboardAnalyzeSensorDataFailure(failure)),
      (response) => emit(ProjectDashboardAnalyzeSensorDataSuccess(response)),
    );
  }

  void updateSensorData(SensorDataResponse sensorData) {
    if (lastTimeDbResponse != null && lastTimeDbResponse!.result != null) {
      final existingResult = lastTimeDbResponse!.result!;
      final Map<String, Data> updatedFields = Map.from(existingResult.fields);

      // Update only the fields that exist in the new data
      if (sensorData.result != null) {
        sensorData.result!.fields.forEach((key, value) {
          updatedFields[key] = value;
        });
      }

      final newResult = Result(fields: updatedFields);

      final updatedResponse = SensorDataResponse(
        result: newResult,
        dominate_frequencies: sensorData.dominate_frequencies,
        magnitude: sensorData.magnitude,
        frequency: sensorData.frequency,
      );

      lastTimeDbResponse = updatedResponse;
      emit(ProjectDashboardDetailsTimeDbSuccess(updatedResponse));
    } else {
      lastTimeDbResponse = sensorData;
      emit(ProjectDashboardDetailsTimeDbSuccess(sensorData));
    }
  }

  Future<void> createDash(
      String name, String description, String group, int projectId) async {
    emit(ProjectDashboardCreateDashLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.createDash(
        token, name, description, group, projectId);
    res.fold(
      (failure) => emit(ProjectDashboardCreateDashFailure(failure)),
      (response) => emit(ProjectDashboardCreateDashSuccess(response)),
    );
  }

  Future<void> getMonitoring(int projectId) async {
    emit(ProjectDashboardMonitoringLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getMonitoring(token, projectId);
    res.fold(
      (failure) => emit(ProjectDashboardMonitoringFailure(failure)),
      (response) => emit(ProjectDashboardMonitoringSuccess(response)),
    );
  }

  MonitoringCloudHubResponse? monitoringCloudHubResponse;
  Future<void> getMonitoringCloudHub() async {
    emit(ProjectDashboardMonitoringCloudHubLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getMonitoringCloudHub(token);
    res.fold(
      (failure) => emit(ProjectDashboardMonitoringCloudHubFailure(failure)),
      (response) {
        monitoringCloudHubResponse = response;
        emit(ProjectDashboardMonitoringCloudHubSuccess(response));
      },
    );
  }

  Future<void> getSensorData(int sensorId) async {
    emit(ProjectDashboardSensorDataLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getSensorData(token, sensorId);
    res.fold(
      (failure) => emit(ProjectDashboardSensorDataFailure(failure)),
      (response) => emit(ProjectDashboardSensorDataSuccess(response)),
    );
  }

  Future<void> getCloudhubData(int cloudhubId) async {
    emit(ProjectDashboardCloudhubDataLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getCloudhubData(token, cloudhubId);
    res.fold(
      (failure) => emit(ProjectDashboardCloudhubDataFailure(failure)),
      (response) => emit(ProjectDashboardCloudhubDataSuccess(response)),
    );
  }
}
