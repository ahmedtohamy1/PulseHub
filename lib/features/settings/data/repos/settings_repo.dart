import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/settings/data/models/manage_session_response.dart';

abstract class SettingsRepository {
  Future<Either<String, ManageSessionResponse>> getSettions(String token);
}
