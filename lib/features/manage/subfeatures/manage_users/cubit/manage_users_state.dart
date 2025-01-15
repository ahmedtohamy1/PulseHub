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
