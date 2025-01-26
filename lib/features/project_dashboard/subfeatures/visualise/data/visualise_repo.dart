import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_medial_library_response_model.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/data/models/get_dash_components.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/data/models/get_one_dash_components.dart';

abstract class VisualiseRepo {
  Future<Either<String, bool>> saveImageWithSensor(
    String token,
    int dashboardId,
    String componentName,
    String imageName,
    List<Map<String, Map<String, dynamic>>> sensorsIdsAndCoordinates,
  );

  Future<Either<String, bool>> createMediaLibraryFile(
      String token, int projectId, String fileName, XFile file);

  Future<Either<String, GetOneDashComponents>> getImageWithSensors(
    String token,
    int dashboardId,
  );

  Future<Either<String, GetMediaLibrariesResponseModel>> getMediaLibrary(
      String token, int projectId);
}
