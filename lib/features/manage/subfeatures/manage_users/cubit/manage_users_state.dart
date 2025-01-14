part of 'manage_users_cubit.dart';

sealed class ManageUsersState extends Equatable {
  const ManageUsersState();

  @override
  List<Object> get props => [];
}

final class ManageUsersInitial extends ManageUsersState {}
