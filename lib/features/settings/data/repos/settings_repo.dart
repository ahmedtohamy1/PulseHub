import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/settings/data/models/get_notifications_response_model.dart';
import 'package:pulsehub/features/settings/data/models/manage_session_response.dart';
import 'package:pulsehub/features/settings/data/models/user_details.dart';

abstract class SettingsRepository {
  Future<Either<String, ManageSessionResponse>> getSettions(String token);
  Future<Either<String, String>> deleteSession(String token, String sessionId);
  Future<Either<String, UserDetails>> getUserDetails(String token);
  Future<Either<String, String>> updateUserDetails(
      String token,
      String email,
      String firstName,
      String lastName,
      String title,
      String picture,
      String mode);
  Future logout(String refreshToken, String token);
  Future resetPassword(String password, String newPassword,
      String confirmPassword, String token);
  Future<Either<String, GetNotificationResponseModel>> getNotifications(
      String token);
  Future<Either<String, int>> getUnseenMessages(String token);
}
