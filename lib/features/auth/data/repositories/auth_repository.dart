import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/auth/data/models/otp_verify.dart';

abstract class AuthRepository {
  Future<Either<String, dynamic>> login(String email, String password);

  Future sendPasswordResetCode(String email);
  Future verifyResetPasswordOTP(
      String email, String otp, String password, String confirmPassword);

  Future<Either<String, OtpVerify>> verifyLoginOTP(
      String otp, String otpAccess, bool remeberMe);
}
