part of 'manage_sensors_cubit.dart';

sealed class ManageSensorsState extends Equatable {
  const ManageSensorsState();

  @override
  List<Object> get props => [];
}

final class ManageSensorsInitial extends ManageSensorsState {}

final class ManageSensorsLoading extends ManageSensorsState {}

final class ManageSensorsLoaded extends ManageSensorsState {
  final GetAllSensorTypesResponseModel sensorTypes;

  const ManageSensorsLoaded(this.sensorTypes);
}

final class ManageSensorsError extends ManageSensorsState {
  final String error;

  const ManageSensorsError(this.error);
}

final class DeleteSensorTypeLoading extends ManageSensorsState {}

final class DeleteSensorTypeSuccess extends ManageSensorsState {}

final class DeleteSensorTypeError extends ManageSensorsState {
  final String error;

  const DeleteSensorTypeError(this.error);
}
