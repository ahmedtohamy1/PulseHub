part of 'manage_users_cubit.dart';

sealed class ManageUsersState extends Equatable {
  const ManageUsersState();

  @override
  List<Object> get props => [];
}

final class ManageUsersInitial extends ManageUsersState {}

final class ManageUsersLoading extends ManageUsersState {}

final class ManageUsersSuccess extends ManageUsersState {
  final GetAllResponseModel response;

  const ManageUsersSuccess(this.response);
}

final class ManageUsersFailure extends ManageUsersState {
  final String error;

  const ManageUsersFailure(this.error);
} 

final class ManageUsersDeleteLoading extends ManageUsersState {}

final class ManageUsersDeleteSuccess extends ManageUsersState {
  final bool success;

  const ManageUsersDeleteSuccess(this.success);
}
  
final class ManageUsersDeleteFailure extends ManageUsersState {
  final String error;

  const ManageUsersDeleteFailure(this.error);
}

final class ManageUsersUpdateLoading extends ManageUsersState {}

final class ManageUsersUpdateSuccess extends ManageUsersState {
  final bool success;

  const ManageUsersUpdateSuccess(this.success);
}

final class ManageUsersUpdateFailure extends ManageUsersState {
  final String error;

  const ManageUsersUpdateFailure(this.error);
}

final class ManageUsersGetUserProjectsLoading extends ManageUsersState {}

final class ManageUsersGetUserProjectsSuccess extends ManageUsersState {
  final GetUsersProjects response;

  const ManageUsersGetUserProjectsSuccess(this.response);
}

final class ManageUsersGetUserProjectsFailure extends ManageUsersState {
  final String error;

  const ManageUsersGetUserProjectsFailure(this.error);
}
