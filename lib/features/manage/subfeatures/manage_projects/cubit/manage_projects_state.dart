part of 'manage_projects_cubit.dart';

sealed class ManageProjectsState extends Equatable {
  const ManageProjectsState();

  @override
  List<Object> get props => [];
}

final class ManageProjectsInitial extends ManageProjectsState {}
