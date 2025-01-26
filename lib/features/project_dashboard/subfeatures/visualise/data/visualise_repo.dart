import 'package:fpdart/fpdart.dart';

abstract class VisualiseRepo {
  Future<Either<String, bool>> saveImageWithSensor(
    String token,
    int dashboardId,
    String componentName,
    String imageName,
    List<Map<String, Map<String, dynamic>>> sensorsIdsAndCoordinates,
  );
}
