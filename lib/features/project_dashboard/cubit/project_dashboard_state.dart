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
