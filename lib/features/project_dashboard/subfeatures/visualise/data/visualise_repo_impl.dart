import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_medial_library_response_model.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/data/models/get_one_dash_components.dart';
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

  @override
  Future<Either<String, bool>> createMediaLibraryFile(
      String token, int projectId, String fileName, XFile file) async {
    try {
      // Create form data
      final formData = FormData.fromMap({
        'project': projectId,
        'file_name': fileName,
        'description': 'Dashboard 2d sensor placement component image',
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
      });

      final response = await myApi.post(
        EndPoints.mediaLibrary,
        token: token,
        data: formData,
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left(
            'Failed to create media library file: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, GetOneDashComponents>> getImageWithSensors(
      String token, int dashboardId) async {
    try {
      final response = await myApi.get(
        EndPoints.createDash,
        token: token,
        queryParameters: {'dashboard_id': dashboardId},
      );

      if (response.statusCode == StatusCode.ok) {
        return Right(GetOneDashComponents.fromJson(response.data));
      }

      return Left('Failed to get image with sensors: ${response.data}');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, GetMediaLibrariesResponseModel>> getMediaLibrary(
      String token, int projectId) async {
    try {
      final response = await myApi.get(
        EndPoints.mediaLibrary,
        token: token,
        queryParameters: {'project_id': projectId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(GetMediaLibrariesResponseModel.fromJson(response.data));
      } else {
        return Left('Failed to get media library: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> updateDashboardComponent(
      String token,
      int dashboardId,
      int componentId,
      String componentName,
      String imageName,
      List<Map<String, Map<String, dynamic>>> sensorsIdsAndCoordinates) async {
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
        queryParameters: {'component_id': componentId},
        encodeAsJson: true,
        data: requestBody,
      );

      if (response.statusCode == StatusCode.ok ||
          response.statusCode == StatusCode.created) {
        return right(true);
      }

      return left('Failed to save image with sensors: ${response.data}');
    } catch (e) {
      return left(e.toString());
    }
  }
}
