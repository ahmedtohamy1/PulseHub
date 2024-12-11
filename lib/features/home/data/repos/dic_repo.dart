import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/home/data/dic_services_model.dart';

abstract class DicRepository {
  Future<Either<String, DicServicesResponse>> getDics(
      String token, String userId);
}
