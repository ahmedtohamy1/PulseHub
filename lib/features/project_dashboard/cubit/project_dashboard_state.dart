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
