part of 'manage_projects_cubit.dart';

abstract class ManageProjectsState extends Equatable {
  const ManageProjectsState();

  @override
  List<Object?> get props => [];
}

class ManageProjectsInitial extends ManageProjectsState {}

class GetAllProjectsLoading extends ManageProjectsState {}

class GetAllProjectsSuccess extends ManageProjectsState {
  final GetAllProjectsResponseModel projects;

  const GetAllProjectsSuccess(this.projects);

  @override
  List<Object?> get props => [projects];
}

class GetAllProjectsFailure extends ManageProjectsState {
  final String error;

  const GetAllProjectsFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class GetAllOwnersLoading extends ManageProjectsState {}

class GetAllOwnersSuccess extends ManageProjectsState {
  final List<owner.OwnerModel> owners;

  const GetAllOwnersSuccess(this.owners);

  @override
  List<Object?> get props => [owners];
}

class GetAllOwnersFailure extends ManageProjectsState {
  final String error;

  const GetAllOwnersFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class CreateOwnerLoading extends ManageProjectsState {}

class CreateOwnerSuccess extends ManageProjectsState {}

class CreateOwnerFailure extends ManageProjectsState {
  final String error;

  const CreateOwnerFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class CreateProjectLoading extends ManageProjectsState {}

class CreateProjectSuccess extends ManageProjectsState {}

class CreateProjectFailure extends ManageProjectsState {
  final String error;

  const CreateProjectFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class DeleteProjectLoading extends ManageProjectsState {
  final int projectId;

  const DeleteProjectLoading(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class DeleteProjectSuccess extends ManageProjectsState {}

class DeleteProjectFailure extends ManageProjectsState {
  final String error;

  const DeleteProjectFailure(this.error);

  @override
  List<Object?> get props => [error];
}
