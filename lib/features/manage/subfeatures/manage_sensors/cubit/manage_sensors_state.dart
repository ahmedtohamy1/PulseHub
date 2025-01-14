part of 'manage_sensors_cubit.dart';

sealed class ManageSensorsState extends Equatable {
  const ManageSensorsState();

  @override
  List<Object> get props => [];
}

final class ManageSensorsInitial extends ManageSensorsState {}
