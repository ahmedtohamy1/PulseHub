part of 'project_dashboard_cubit.dart';

sealed class ProjectDashboardState extends Equatable {
  const ProjectDashboardState();

  @override
  List<Object> get props => [];
}

final class ProjectDashboardInitial extends ProjectDashboardState {}

final class ProjectDashboardFetchLoading extends ProjectDashboardState {}

final class ProjectDashboardFetchSuccess extends ProjectDashboardState {
  final ProjectDashboards projectDashboards;

  const ProjectDashboardFetchSuccess(this.projectDashboards);

  @override
  List<Object> get props => [projectDashboards];
}

final class ProjectDashboardFetchFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardFetchFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardDetailsLoading extends ProjectDashboardState {}

final class ProjectDashboardDetailsSuccess extends ProjectDashboardState {
  final CloudHubResponse cloudHubResponse;

  const ProjectDashboardDetailsSuccess(this.cloudHubResponse);

  @override
  List<Object> get props => [cloudHubResponse];
}

final class ProjectDashboardDetailsFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardDetailsFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardDetailsTimeDbLoading
    extends ProjectDashboardState {}

final class ProjectDashboardDetailsTimeDbSuccess extends ProjectDashboardState {
  final SensorDataResponse sensorDataResponse;

  const ProjectDashboardDetailsTimeDbSuccess(this.sensorDataResponse);

  @override
  List<Object> get props => [sensorDataResponse];
}

final class ProjectDashboardDetailsTimeDbFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardDetailsTimeDbFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardCreateDashLoading extends ProjectDashboardState {}

final class ProjectDashboardCreateDashSuccess extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardCreateDashSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardCreateDashFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardCreateDashFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardMonitoringLoading extends ProjectDashboardState {}

final class ProjectDashboardMonitoringSuccess extends ProjectDashboardState {
  final MonitoringResponse monitoringResponse;

  const ProjectDashboardMonitoringSuccess(this.monitoringResponse);

  @override
  List<Object> get props => [monitoringResponse];
}

final class ProjectDashboardMonitoringFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardMonitoringFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardMonitoringCloudHubLoading
    extends ProjectDashboardState {}

final class ProjectDashboardMonitoringCloudHubSuccess
    extends ProjectDashboardState {
  final MonitoringCloudHubResponse monitoringCloudHubResponse;

  const ProjectDashboardMonitoringCloudHubSuccess(
      this.monitoringCloudHubResponse);

  @override
  List<Object> get props => [monitoringCloudHubResponse];
}

final class ProjectDashboardMonitoringCloudHubFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardMonitoringCloudHubFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardSensorDataLoading extends ProjectDashboardState {}

final class ProjectDashboardSensorDataSuccess extends ProjectDashboardState {
  final SensorDataResponse sensorDataResponse;

  const ProjectDashboardSensorDataSuccess(this.sensorDataResponse);

  @override
  List<Object> get props => [sensorDataResponse];
}

final class ProjectDashboardSensorDataFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardSensorDataFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardAnalyzeSensorDataLoading
    extends ProjectDashboardState {}

final class ProjectDashboardAnalyzeSensorDataSuccess
    extends ProjectDashboardState {
  final AiAnalyzeDataModel aiAnalyzeDataModel;

  const ProjectDashboardAnalyzeSensorDataSuccess(this.aiAnalyzeDataModel);

  @override
  List<Object> get props => [aiAnalyzeDataModel];
}

final class ProjectDashboardAnalyzeSensorDataFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardAnalyzeSensorDataFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardCloudhubDataLoading extends ProjectDashboardState {}

final class ProjectDashboardCloudhubDataSuccess extends ProjectDashboardState {
  final MonitoringCloudhubDetails cloudhubDetails;

  const ProjectDashboardCloudhubDataSuccess(this.cloudhubDetails);

  @override
  List<Object> get props => [cloudhubDetails];
}

final class ProjectDashboardCloudhubDataFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardCloudhubDataFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardSensorActivityLogLoading
    extends ProjectDashboardState {}

final class ProjectDashboardSensorActivityLogSuccess
    extends ProjectDashboardState {
  final SensorActivityLog sensorActivityLog;

  const ProjectDashboardSensorActivityLogSuccess(this.sensorActivityLog);

  @override
  List<Object> get props => [sensorActivityLog];
}

final class ProjectDashboardSensorActivityLogFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardSensorActivityLogFailure(this.message);
}

final class ProjectDashboardUpdateProjectLoading
    extends ProjectDashboardState {}

final class ProjectDashboardUpdateProjectSuccess extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardUpdateProjectSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardUpdateProjectFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardUpdateProjectFailure(this.message);
}

final class ProjectDashboardDeleteProjectLoading
    extends ProjectDashboardState {}

final class ProjectDashboardDeleteProjectSuccess extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardDeleteProjectSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardDeleteProjectFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardDeleteProjectFailure(this.message);
}

final class ProjectDashboardGetUsedSensorsLoading
    extends ProjectDashboardState {}

final class ProjectDashboardGetUsedSensorsSuccess
    extends ProjectDashboardState {
  final GetUsedSensorsResponseModel getUsedSensorsResponseModel;

  const ProjectDashboardGetUsedSensorsSuccess(this.getUsedSensorsResponseModel);

  @override
  List<Object> get props => [getUsedSensorsResponseModel];
}

final class ProjectDashboardGetUsedSensorsFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardGetUsedSensorsFailure(this.message);
}

final class ProjectDashboardUpdateUsedSensorsLoading
    extends ProjectDashboardState {}

final class ProjectDashboardUpdateUsedSensorsSuccess
    extends ProjectDashboardState {
  final bool getUsedSensorsResponseModel;

  const ProjectDashboardUpdateUsedSensorsSuccess(
      this.getUsedSensorsResponseModel);

  @override
  List<Object> get props => [getUsedSensorsResponseModel];
}

final class ProjectDashboardUpdateUsedSensorsFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardUpdateUsedSensorsFailure(this.message);
}

final class ProjectDashboardCreateUsedSensorsLoading
    extends ProjectDashboardState {}

final class ProjectDashboardCreateUsedSensorsSuccess
    extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardCreateUsedSensorsSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardCreateUsedSensorsFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardCreateUsedSensorsFailure(this.message);
}

final class ProjectDashboardCreateMediaLibraryFileLoading
    extends ProjectDashboardState {}

final class ProjectDashboardCreateMediaLibraryFileSuccess
    extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardCreateMediaLibraryFileSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardCreateMediaLibraryFileFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardCreateMediaLibraryFileFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardGetMediaLibraryLoading
    extends ProjectDashboardState {}

final class ProjectDashboardGetMediaLibrarySuccess
    extends ProjectDashboardState {
  final GetMediaLibrariesResponseModel getMediaLibrariesResponseModel;

  const ProjectDashboardGetMediaLibrarySuccess(
      this.getMediaLibrariesResponseModel);

  @override
  List<Object> get props => [getMediaLibrariesResponseModel];
}

final class ProjectDashboardGetMediaLibraryFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardGetMediaLibraryFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardDeleteMediaLibraryLoading
    extends ProjectDashboardState {}

final class ProjectDashboardDeleteMediaLibrarySuccess
    extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardDeleteMediaLibrarySuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardDeleteMediaLibraryFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardDeleteMediaLibraryFailure(this.message);
}

final class ProjectDashboardGetCollaboratorsLoading
    extends ProjectDashboardState {}

final class ProjectDashboardGetCollaboratorsSuccess
    extends ProjectDashboardState {
  final GetCollaboratorsResponseModel getCollaboratorsResponseModel;

  const ProjectDashboardGetCollaboratorsSuccess(
      this.getCollaboratorsResponseModel);

  @override
  List<Object> get props => [getCollaboratorsResponseModel];
}

final class ProjectDashboardGetCollaboratorsFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardGetCollaboratorsFailure(this.message);
}

final class ProjectDashboardUpdateCollaboratorsLoading
    extends ProjectDashboardState {}

final class ProjectDashboardUpdateCollaboratorsSuccess
    extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardUpdateCollaboratorsSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardUpdateCollaboratorsFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardUpdateCollaboratorsFailure(this.message);
}

final class ProjectDashboardDeleteCollaboratorsLoading
    extends ProjectDashboardState {}

final class ProjectDashboardDeleteCollaboratorsSuccess
    extends ProjectDashboardState {
  final bool response;

  const ProjectDashboardDeleteCollaboratorsSuccess(this.response);

  @override
  List<Object> get props => [response];
}

final class ProjectDashboardDeleteCollaboratorsFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardDeleteCollaboratorsFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardCreateCollaboratorsGroupLoading
    extends ProjectDashboardState {}

final class ProjectDashboardCreateCollaboratorsGroupSuccess
    extends ProjectDashboardState {
  final bool response;

  const ProjectDashboardCreateCollaboratorsGroupSuccess(this.response);

  @override
  List<Object> get props => [response];
}

final class ProjectDashboardCreateCollaboratorsGroupFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardCreateCollaboratorsGroupFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardAddUserToCollaboratorsGroupLoading
    extends ProjectDashboardState {}

final class ProjectDashboardAddUserToCollaboratorsGroupSuccess
    extends ProjectDashboardState {
  final bool response;

  const ProjectDashboardAddUserToCollaboratorsGroupSuccess(this.response);

  @override
  List<Object> get props => [response];
}

final class ProjectDashboardAddUserToCollaboratorsGroupFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardAddUserToCollaboratorsGroupFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardRemoveUserFromCollaboratorsGroupLoading
    extends ProjectDashboardState {}

final class ProjectDashboardRemoveUserFromCollaboratorsGroupSuccess
    extends ProjectDashboardState {
  final bool response;

  const ProjectDashboardRemoveUserFromCollaboratorsGroupSuccess(this.response);

  @override
  List<Object> get props => [response];
}

final class ProjectDashboardRemoveUserFromCollaboratorsGroupFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardRemoveUserFromCollaboratorsGroupFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardGetAllUsersLoading extends ProjectDashboardState {}

final class ProjectDashboardGetAllUsersSuccess extends ProjectDashboardState {
  final GetAllResponseModel getAllResponseModel;

  const ProjectDashboardGetAllUsersSuccess(this.getAllResponseModel);

  @override
  List<Object> get props => [getAllResponseModel];
}

final class ProjectDashboardGetAllUsersFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardGetAllUsersFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardUpdateCloudhubLoading extends ProjectDashboardState {}

final class ProjectDashboardUpdateCloudhubSuccess extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardUpdateCloudhubSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardUpdateCloudhubFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardUpdateCloudhubFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardMarkMessageAsSeenLoading
    extends ProjectDashboardState {}

final class ProjectDashboardMarkMessageAsSeenSuccess
    extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardMarkMessageAsSeenSuccess(this.success);
}

final class ProjectDashboardMarkMessageAsSeenFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardMarkMessageAsSeenFailure(this.message);
}

final class ProjectDashboardCreateCloudhubSensorLoading
    extends ProjectDashboardState {}

final class ProjectDashboardCreateCloudhubSensorSuccess
    extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardCreateCloudhubSensorSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardCreateCloudhubSensorFailure
    extends ProjectDashboardState {
  final String message;

  const ProjectDashboardCreateCloudhubSensorFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class ProjectDashboardDeleteDashLoading extends ProjectDashboardState {}

  final class ProjectDashboardDeleteDashSuccess extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardDeleteDashSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardDeleteDashFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardDeleteDashFailure(this.message);
}

final class ProjectDashboardUpdateDashLoading extends ProjectDashboardState {}

final class ProjectDashboardUpdateDashSuccess extends ProjectDashboardState {
  final bool success;

  const ProjectDashboardUpdateDashSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class ProjectDashboardUpdateDashFailure extends ProjectDashboardState {
  final String message;

  const ProjectDashboardUpdateDashFailure(this.message);
}
