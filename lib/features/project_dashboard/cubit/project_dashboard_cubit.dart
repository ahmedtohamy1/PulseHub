import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/project_dashboard/data/models/ai_analyze_data_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_medial_library_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_used_sensors_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_details.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_update_request.dart';
import 'package:pulsehub/features/project_dashboard/data/models/sensor_activity_log_model.dart';
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
        // If this is a single field update (from analyze button)
        if (queryParams.fields == queryParams.sensorsToAnalyze &&
            lastTimeDbResponse != null) {
          updateSensorData(response);
        } else {
          // If this is a full update (from submit button)
          lastTimeDbResponse = response;
          emit(ProjectDashboardDetailsTimeDbSuccess(response));
        }
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

      // Keep existing frequency/magnitude data for fields not being updated
      final Map<String, List<double>> updatedFrequency =
          Map.from(lastTimeDbResponse!.frequency ?? {});
      final Map<String, List<double>> updatedMagnitude =
          Map.from(lastTimeDbResponse!.magnitude ?? {});
      final Map<String, List<double>> updatedDominateFrequencies =
          Map.from(lastTimeDbResponse!.dominate_frequencies ?? {});
      final Map<String, double> updatedAnomalyPercentage =
          Map.from(lastTimeDbResponse!.anomaly_percentage ?? {});
      final Map<String, List<List<double>>> updatedAnomalyRegions =
          Map.from(lastTimeDbResponse!.anomaly_regions ?? {});
      final Map<String, dynamic> updatedTicket =
          Map.from(lastTimeDbResponse!.ticket ?? {});
      final Map<String, dynamic> updatedOpenTicket =
          Map.from(lastTimeDbResponse!.open_ticket ?? {});

      // Update only the fields that exist in the new data
      if (sensorData.frequency != null)
        updatedFrequency.addAll(sensorData.frequency!);
      if (sensorData.magnitude != null)
        updatedMagnitude.addAll(sensorData.magnitude!);
      if (sensorData.dominate_frequencies != null)
        updatedDominateFrequencies.addAll(sensorData.dominate_frequencies!);
      if (sensorData.anomaly_percentage != null)
        updatedAnomalyPercentage.addAll(sensorData.anomaly_percentage!);
      if (sensorData.anomaly_regions != null)
        updatedAnomalyRegions.addAll(sensorData.anomaly_regions!);
      if (sensorData.ticket != null) updatedTicket.addAll(sensorData.ticket!);
      if (sensorData.open_ticket != null)
        updatedOpenTicket.addAll(sensorData.open_ticket!);

      final newResult = Result(fields: updatedFields);

      final updatedResponse = SensorDataResponse(
        result: newResult,
        frequency: updatedFrequency,
        magnitude: updatedMagnitude,
        dominate_frequencies: updatedDominateFrequencies,
        anomaly_percentage: updatedAnomalyPercentage,
        anomaly_regions: updatedAnomalyRegions,
        ticket: updatedTicket,
        open_ticket: updatedOpenTicket,
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

  Future<void> getSensorActivityLog(int sensorId) async {
    emit(ProjectDashboardSensorActivityLogLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getSensorActivityLog(token, sensorId);
    res.fold(
      (failure) => emit(ProjectDashboardSensorActivityLogFailure(failure)),
      (response) => emit(ProjectDashboardSensorActivityLogSuccess(response)),
    );
  }

  Future<void> updateProject(
      int projectId, ProjectUpdateRequest request) async {
    emit(ProjectDashboardUpdateProjectLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.updateProject(token, projectId, request);
    res.fold(
      (failure) => emit(ProjectDashboardUpdateProjectFailure(failure)),
      (response) => emit(ProjectDashboardUpdateProjectSuccess(response)),
    );
  }

  Future<void> deleteProject(int projectId) async {
    emit(ProjectDashboardDeleteProjectLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.deleteProject(token, projectId);
    res.fold(
      (failure) => emit(ProjectDashboardDeleteProjectFailure(failure)),
      (response) => emit(ProjectDashboardDeleteProjectSuccess(response)),
    );
  }

  Future<void> getUsedSensors() async {
    emit(ProjectDashboardGetUsedSensorsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getUsedSensors(token);
    res.fold(
      (failure) => emit(ProjectDashboardGetUsedSensorsFailure(failure)),
      (response) => emit(ProjectDashboardGetUsedSensorsSuccess(response)),
    );
  }

  Future<void> updateUsedSensors(int id, int count, [bool? isdelete]) async {
    emit(ProjectDashboardUpdateUsedSensorsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = isdelete != null && isdelete == true
        ? await _repository.deleteUsedSensors(token, id)
        : await _repository.updateUsedSensors(token, id, count);
    res.fold(
      (failure) => emit(ProjectDashboardUpdateUsedSensorsFailure(failure)),
      (response) => emit(ProjectDashboardUpdateUsedSensorsSuccess(response)),
    );
  }

  Future<void> createUsedSensors(
      int usedSensorTypeId, int count, int monitoringId) async {
    emit(ProjectDashboardCreateUsedSensorsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.createUsedSensors(
        token, usedSensorTypeId, count, monitoringId);
    res.fold(
      (failure) => emit(ProjectDashboardCreateUsedSensorsFailure(failure)),
      (response) => emit(ProjectDashboardCreateUsedSensorsSuccess(response)),
    );
  }

  Future<void> createMediaLibraryFile(String token, int projectId,
      String fileName, String fileDescription, PlatformFile file) async {
    emit(ProjectDashboardCreateMediaLibraryFileLoading());
    final res = await _repository.createMediaLibraryFile(
      token,
      projectId,
      fileName,
      fileDescription,
      file,
    );
    res.fold(
      (failure) => emit(ProjectDashboardCreateMediaLibraryFileFailure(failure)),
      (response) =>
          emit(ProjectDashboardCreateMediaLibraryFileSuccess(response)),
    );
  }

  Future<void> getMediaLibrary(int projectId) async {
    emit(ProjectDashboardGetMediaLibraryLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getMediaLibrary(token, projectId);
    res.fold(
      (failure) => emit(ProjectDashboardGetMediaLibraryFailure(failure)),
      (response) => emit(ProjectDashboardGetMediaLibrarySuccess(response)),
    );
  }
}
