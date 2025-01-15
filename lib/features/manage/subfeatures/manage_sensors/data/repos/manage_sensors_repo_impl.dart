import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_sensors/data/models/get_all_sensor_types_response_model.dart';

import 'manage_sensors_repo.dart';

@Injectable(as: ManageSensorsRepository)
class ManageSensorsRepositoryImpl implements ManageSensorsRepository {
  final MyApi myApiService;

  ManageSensorsRepositoryImpl(this.myApiService);

  @override
  Future<Either<String, GetAllSensorTypesResponseModel>> getAllSensorTypes(
      String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.getAllSensorTypes,
        token: token,
      );
      if (StatusCode.ok == response.statusCode ||
          StatusCode.created == response.statusCode) {
        return right(GetAllSensorTypesResponseModel.fromJson(response.data));
      } else {
        return left(response.statusCode.toString());
      }
    } catch (e) {
      return left(e.toString());
    }
  }
}
