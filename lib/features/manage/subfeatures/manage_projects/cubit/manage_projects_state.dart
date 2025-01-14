part of 'manage_projects_cubit.dart';

sealed class ManageProjectsState extends Equatable {
  const ManageProjectsState();

  @override
  List<Object> get props => [];
}

final class ManageProjectsInitial extends ManageProjectsState {}

final class GetAllProjectsLoading extends ManageProjectsState {}

final class GetAllProjectsSuccess extends ManageProjectsState {
  final GetAllProjectsResponseModel projects;

  const GetAllProjectsSuccess(this.projects);

  @override
  List<Object> get props => [projects];
}

final class GetAllProjectsFailure extends ManageProjectsState {
  final String message;

  const GetAllProjectsFailure(this.message);

  @override
  List<Object> get props => [message];
}
