import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/data/visualise_repo.dart';

@Injectable(as: VisualiseRepo)
class VisualiseRepoImpl implements VisualiseRepo {
  final MyApi myApi;

  VisualiseRepoImpl(this.myApi);

  @override
  Future<Either<String, bool>> saveImageWithSensor(
    String token,
    int dashboardId,
    String componentName,
    String imageName,
    List<Map<String, Map<String, dynamic>>> sensorsIdsAndCoordinates,
  ) async {
    try {
      // Convert sensor coordinates to required format: { sensorId: [x, y] }
      final formattedSensors = <String, List<double>>{};
      for (final sensorMap in sensorsIdsAndCoordinates) {
        sensorMap.forEach((sensorId, coordinates) {
          formattedSensors[sensorId] = [
            (coordinates['x'] as num).toDouble(),
            (coordinates['y'] as num).toDouble(),
          ];
        });
      }

      final content = {
        "picture_name": imageName,
        "sensors": formattedSensors,
      };


      final requestBody = {
        'dashboard': dashboardId,
        'name': componentName,
        'content': content,
      };


      final response = await myApi.post(
        EndPoints.saveImageWithSensor,
        token: token,
        encodeAsJson: true,
        data: requestBody,
      );


      if (response.statusCode == StatusCode.created) {
        return right(true);
      }

      return left('Failed to save image with sensors: ${response.data}');
    } catch (e) {
      return left(e.toString());
    }
  }
}
