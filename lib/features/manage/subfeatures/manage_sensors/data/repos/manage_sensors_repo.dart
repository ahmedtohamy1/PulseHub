import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_sensors/data/models/get_all_sensor_types_response_model.dart';

abstract class ManageSensorsRepository {
  Future<Either<String, GetAllSensorTypesResponseModel>> getAllSensorTypes(
      String token);

  Future<Either<String, void>> deleteSensorType(String token, int sensorTypeId);

  Future<Either<String, void>> createEditSensorType(String token,
      String name, String function, int? id);
}
