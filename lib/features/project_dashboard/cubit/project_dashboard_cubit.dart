import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/project_dashboard/data/models/ai_analyze_data_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/ai_q2_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_collaborators_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_medial_library_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_used_sensors_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_details.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_update_request.dart';
import 'package:pulsehub/features/project_dashboard/data/models/sensor_activity_log_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';
import 'package:pulsehub/features/project_dashboard/data/models/update_cloudhub_request_model.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo_impl.dart';

part 'project_dashboard_state.dart';

@injectable
class ProjectDashboardCubit extends Cubit<ProjectDashboardState> {
  final DashRepository _repository;

  ProjectDashboardCubit(this._repository) : super(ProjectDashboardInitial());

  // Cache for analysis results
  AiAnalyzeDataModel? _cachedAnalyzeResult;
  AiQ2ResponseModel? _cachedExpertResult;

  AiAnalyzeDataModel? get cachedAnalyzeResult => _cachedAnalyzeResult;
  AiQ2ResponseModel? get cachedExpertResult => _cachedExpertResult;

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
  GetCollaboratorsResponseModel? cachedCollaborators;

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
      (response) {
        _cachedAnalyzeResult = response;
        emit(ProjectDashboardAnalyzeSensorDataSuccess(response));
      },
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
      if (sensorData.frequency != null) {
        updatedFrequency.addAll(sensorData.frequency!);
      }
      if (sensorData.magnitude != null) {
        updatedMagnitude.addAll(sensorData.magnitude!);
      }
      if (sensorData.dominate_frequencies != null) {
        updatedDominateFrequencies.addAll(sensorData.dominate_frequencies!);
      }
      if (sensorData.anomaly_percentage != null) {
        updatedAnomalyPercentage.addAll(sensorData.anomaly_percentage!);
      }
      if (sensorData.anomaly_regions != null) {
        updatedAnomalyRegions.addAll(sensorData.anomaly_regions!);
      }
      if (sensorData.ticket != null) updatedTicket.addAll(sensorData.ticket!);
      if (sensorData.open_ticket != null) {
        updatedOpenTicket.addAll(sensorData.open_ticket!);
      }

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

  Future<void> deleteDash(int dashId) async {
    emit(ProjectDashboardDeleteDashLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.deleteDash(token, dashId);
    res.fold(
      (failure) => emit(ProjectDashboardDeleteDashFailure(failure)),
      (response) => emit(ProjectDashboardDeleteDashSuccess(response)),
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

  Future<void> updateDash(int dashId, String name, String description) async {
    emit(ProjectDashboardUpdateDashLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.updateDash(token, dashId, name, description);
    res.fold(
      (failure) => emit(ProjectDashboardUpdateDashFailure(failure)),
      (response) => emit(ProjectDashboardUpdateDashSuccess(response)),
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

  Future<void> deleteMediaLibrary(int mediaLibraryId) async {
    emit(ProjectDashboardDeleteMediaLibraryLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.deleteMediaLibrary(token, mediaLibraryId);
    res.fold(
      (failure) => emit(ProjectDashboardDeleteMediaLibraryFailure(failure)),
      (response) => emit(ProjectDashboardDeleteMediaLibrarySuccess(response)),
    );
  }

  Future<void> getCollaborators(int projectId) async {
    if (cachedCollaborators == null) {
      emit(ProjectDashboardGetCollaboratorsLoading());
    }
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getCollaborators(token, projectId);
    res.fold(
      (failure) => emit(ProjectDashboardGetCollaboratorsFailure(failure)),
      (response) {
        cachedCollaborators = response;
        emit(ProjectDashboardGetCollaboratorsSuccess(response));
      },
    );
  }

  Future<void> updateCollaboratorsGroup(
      int groupId,
      int projectId,
      String name,
      String description,
      bool isAnalyzer,
      bool isViewer,
      bool isEditor,
      bool isMonitor,
      bool isManager,
      bool isNotificationSender) async {
    emit(ProjectDashboardUpdateCollaboratorsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.updateCollaborators(
        token,
        groupId,
        projectId,
        name,
        description,
        isAnalyzer,
        isViewer,
        isEditor,
        isMonitor,
        isManager,
        isNotificationSender);
    res.fold(
      (failure) {
        emit(ProjectDashboardUpdateCollaboratorsFailure(failure));
      },
      (response) async {
        try {
          emit(ProjectDashboardUpdateCollaboratorsSuccess(response));
          // Get updated collaborators list
          final collaboratorsRes =
              await _repository.getCollaborators(token, projectId);
          collaboratorsRes.fold(
            (failure) => emit(ProjectDashboardGetCollaboratorsFailure(failure)),
            (collaborators) {
              cachedCollaborators = collaborators;
              emit(ProjectDashboardGetCollaboratorsSuccess(collaborators));
            },
          );
        } catch (e) {
          emit(ProjectDashboardUpdateCollaboratorsFailure(e.toString()));
        }
      },
    );
  }

  Future<void> deleteCollaboratorsGroup(int groupId, int projectId) async {
    emit(ProjectDashboardDeleteCollaboratorsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.deleteCollaborators(token, groupId);
    res.fold(
      (failure) {
        emit(ProjectDashboardDeleteCollaboratorsFailure(failure));
      },
      (response) async {
        try {
          emit(ProjectDashboardDeleteCollaboratorsSuccess(response));
          // Get updated collaborators list
          final collaboratorsRes =
              await _repository.getCollaborators(token, projectId);
          collaboratorsRes.fold(
            (failure) => emit(ProjectDashboardGetCollaboratorsFailure(failure)),
            (collaborators) {
              cachedCollaborators = collaborators;
              emit(ProjectDashboardGetCollaboratorsSuccess(collaborators));
            },
          );
        } catch (e) {
          emit(ProjectDashboardDeleteCollaboratorsFailure(e.toString()));
        }
      },
    );
  }

  Future<void> createCollaboratorsGroup(
      int projectId,
      String name,
      String description,
      bool isAnalyzer,
      bool isViewer,
      bool isEditor,
      bool isMonitor,
      bool isManager,
      bool isNotificationSender) async {
    emit(ProjectDashboardCreateCollaboratorsGroupLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.createCollaboratorsGroup(
        token,
        projectId,
        name,
        description,
        isAnalyzer,
        isViewer,
        isEditor,
        isMonitor,
        isManager,
        isNotificationSender);
    res.fold(
      (failure) {
        emit(ProjectDashboardCreateCollaboratorsGroupFailure(failure));
      },
      (response) async {
        try {
          emit(ProjectDashboardCreateCollaboratorsGroupSuccess(response));
          // Get updated collaborators list
          final collaboratorsRes =
              await _repository.getCollaborators(token, projectId);
          collaboratorsRes.fold(
            (failure) => emit(ProjectDashboardGetCollaboratorsFailure(failure)),
            (collaborators) {
              cachedCollaborators = collaborators;
              emit(ProjectDashboardGetCollaboratorsSuccess(collaborators));
            },
          );
        } catch (e) {
          emit(ProjectDashboardCreateCollaboratorsGroupFailure(e.toString()));
        }
      },
    );
  }

  Future<void> addUserToCollaboratorsGroup(
      List<int>? groupIds, List<int> userIds,
      {List<int>? projectIds}) async {
    try {
      emit(ProjectDashboardAddUserToCollaboratorsGroupLoading());
      final token =
          await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);

      final res = await _repository.addUserToCollaboratorsGroup(
        token,
        groupIds,
        userIds,
        projectIds: projectIds,
      );

      res.fold(
        (failure) =>
            emit(ProjectDashboardAddUserToCollaboratorsGroupFailure(failure)),
        (response) =>
            emit(ProjectDashboardAddUserToCollaboratorsGroupSuccess(response)),
      );
    } catch (e) {
      emit(ProjectDashboardAddUserToCollaboratorsGroupFailure(e.toString()));
    }
  }

  Future<void> removeUserFromCollaboratorsGroup(
      List<int> groupIds, int userId, int projectId) async {
    emit(ProjectDashboardRemoveUserFromCollaboratorsGroupLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.removeUserFromCollaboratorsGroup(
        token, groupIds, userId);
    res.fold(
      (failure) => emit(
          ProjectDashboardRemoveUserFromCollaboratorsGroupFailure(failure)),
      (response) async {
        try {
          emit(ProjectDashboardRemoveUserFromCollaboratorsGroupSuccess(
              response));
          // Get updated collaborators list
          final collaboratorsRes =
              await _repository.getCollaborators(token, projectId);
          collaboratorsRes.fold(
            (failure) => emit(ProjectDashboardGetCollaboratorsFailure(failure)),
            (collaborators) {
              cachedCollaborators = collaborators;
              emit(ProjectDashboardGetCollaboratorsSuccess(collaborators));
            },
          );
        } catch (e) {
          emit(ProjectDashboardRemoveUserFromCollaboratorsGroupFailure(
              e.toString()));
        }
      },
    );
  }

  Future<void> getAllUsers() async {
    emit(ProjectDashboardGetAllUsersLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getAllUsers(token);
    res.fold(
      (failure) => emit(ProjectDashboardGetAllUsersFailure(failure)),
      (response) => emit(ProjectDashboardGetAllUsersSuccess(response)),
    );
  }

  Future<void> updateCloudhub(
      int cloudhubId, UpdateCloudhubRequestModel request) async {
    emit(ProjectDashboardUpdateCloudhubLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.updateCloudhub(token, cloudhubId, request);
    res.fold(
      (failure) => emit(ProjectDashboardUpdateCloudhubFailure(failure)),
      (response) => emit(ProjectDashboardUpdateCloudhubSuccess(response)),
    );
  }

  Future<void> markMessageAsSeen(int messageId) async {
    emit(ProjectDashboardMarkMessageAsSeenLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.markMessageAsSeen(token, messageId);
    res.fold(
      (failure) => emit(ProjectDashboardMarkMessageAsSeenFailure(failure)),
      (response) => emit(ProjectDashboardMarkMessageAsSeenSuccess(response)),
    );
  }

  Future<void> createCloudhubSensor(int? cloudhubId, int sensorId) async {
    emit(ProjectDashboardCreateCloudhubSensorLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res =
        await _repository.assignCloudhubSensor(token, cloudhubId, sensorId);
    res.fold(
      (failure) => emit(ProjectDashboardCreateCloudhubSensorFailure(failure)),
      (response) => emit(ProjectDashboardCreateCloudhubSensorSuccess(response)),
    );
  }

  Future<void> analyzeSensorDataQ2(String projectId) async {
    emit(ProjectDashboardAnalyzeSensorDataQ2Loading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.analyzeSensorDataQ2(token, projectId);
    res.fold(
      (failure) => emit(ProjectDashboardAnalyzeSensorDataQ2Failure(failure)),
      (response) {
        _cachedExpertResult = response;
        emit(ProjectDashboardAnalyzeSensorDataQ2Success(response));
      },
    );
  }
}
