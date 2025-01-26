part of 'visualise_cubit.dart';

sealed class VisualiseState extends Equatable {
  const VisualiseState();

  @override
  List<Object> get props => [];
}

final class VisualiseInitial extends VisualiseState {}

// Media Library States
final class MediaLibraryLoading extends VisualiseState {}

final class MediaLibrarySuccess extends VisualiseState {}

final class MediaLibraryFailure extends VisualiseState {
  final String message;
  const MediaLibraryFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Sensor Saving States
final class SensorSavingLoading extends VisualiseState {}

final class SensorSavingSuccess extends VisualiseState {}

final class SensorSavingFailure extends VisualiseState {
  final String message;
  const SensorSavingFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Image with sensors states
final class ImageWithSensorsLoading extends VisualiseState {}

final class ImageWithSensorsSuccess extends VisualiseState {
  final GetOneDashComponents components;
  const ImageWithSensorsSuccess(this.components);
}

final class ImageWithSensorsFailure extends VisualiseState {
  final String message;
  const ImageWithSensorsFailure(this.message);
}


final class GetMediaLibraryLoading extends VisualiseState {}

final class GetMediaLibrarySuccess extends VisualiseState {
  final GetMediaLibrariesResponseModel mediaLibraries;
  const GetMediaLibrarySuccess(this.mediaLibraries);
}

final class GetMediaLibraryFailure extends VisualiseState {
  final String message;
  const GetMediaLibraryFailure(this.message);
}
