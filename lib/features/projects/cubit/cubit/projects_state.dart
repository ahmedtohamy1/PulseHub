part of 'projects_cubit.dart';

sealed class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object> get props => [];
}

final class ProjectsInitial extends ProjectsState {}

final class ProjectsLoading extends ProjectsState {}

final class ProjectsLoaded extends ProjectsState {
  final GetProjectsResponse projects;

  const ProjectsLoaded(this.projects);

  @override
  List<Object> get props => [projects];
}

final class ProjectsError extends ProjectsState {
  final String message;

  const ProjectsError(this.message);

  @override
  List<Object> get props => [message];
}

class ProjectDetailsLoaded extends ProjectsState {
  final pr.Project project;

  const ProjectDetailsLoaded(this.project);

  @override
  List<Object> get props => [project];
}
