import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_medial_library_response_model.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/data/models/get_one_dash_components.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/data/visualise_repo.dart';

part 'visualise_state.dart';

@injectable
class VisualiseCubit extends Cubit<VisualiseState> {
  final VisualiseRepo visualiseRepo;
  VisualiseCubit(this.visualiseRepo) : super(VisualiseInitial());

  Future<void> saveImageWithSensors(
      int projectId,
      int dashboardId,
      String componentName,
      XFile imageFile,
      List<Map<String, Map<String, dynamic>>> sensorsIdsAndCoordinates) async {
    emit(MediaLibraryLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);

    // First upload the image
    final imageName = 'scaled_${imageFile.name}';
    final mediaResult = await visualiseRepo.createMediaLibraryFile(
        token, projectId, imageName, imageFile);

    final mediaLibrarySuccess = mediaResult.fold(
      (error) {
        emit(MediaLibraryFailure(error));
        return false;
      },
      (success) {
        emit(MediaLibrarySuccess());
        return true;
      },
    );

    if (!mediaLibrarySuccess) return;

    // Then save the image with sensors
    emit(SensorSavingLoading());
    final sensorResult = await visualiseRepo.saveImageWithSensor(
        token, dashboardId, componentName, imageName, sensorsIdsAndCoordinates);

    sensorResult.fold(
      (error) => emit(SensorSavingFailure(error)),
      (success) => emit(SensorSavingSuccess()),
    );
  }

  Future<void> getImageWithSensors(int dashboardId) async {
    emit(ImageWithSensorsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await visualiseRepo.getImageWithSensors(token, dashboardId);

    result.fold(
      (error) => emit(ImageWithSensorsFailure(error)),
      (success) {
        emit(ImageWithSensorsSuccess(success));
      },
    );
  }

  Future<void> getMediaLibrary(int projectId) async {
    emit(GetMediaLibraryLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await visualiseRepo.getMediaLibrary(token, projectId);

    result.fold(
      (error) => emit(GetMediaLibraryFailure(error)),
      (success) => emit(GetMediaLibrarySuccess(success)),
    );
  }

  Future<void> updateDashboardComponent(
      int dashboardId,
      int componentId,
      String componentName,
      String imageName,
      List<Map<String, Map<String, dynamic>>> sensorsIdsAndCoordinates) async {
    emit(UpdateDashboardComponentLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await visualiseRepo.updateDashboardComponent(
        token,
        dashboardId,
        componentId,
        componentName,
        imageName,
        sensorsIdsAndCoordinates);

    result.fold(
      (error) => emit(UpdateDashboardComponentFailure(error)),
      (success) => emit(UpdateDashboardComponentSuccess()),
    );
  }
}
