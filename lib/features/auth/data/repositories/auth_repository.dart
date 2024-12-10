import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Future<Either<String, dynamic>> login(String email, String password);
  Future logout(String refreshToken);
  Future sendPasswordResetCode(String email);
  Future verifyResetPasswordOTP(
      String email, String otp, String password, String confirmPassword);
}
