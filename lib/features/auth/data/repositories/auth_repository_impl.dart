import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/auth/data/models/login_response_model.dart';
import 'package:pulsehub/features/auth/data/models/otp_login_response.dart';
import 'package:pulsehub/features/auth/data/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final MyApi myApiService;

  AuthRepositoryImpl(this.myApiService);

  @override
  Future<Either<String, dynamic>> login(String email, String password) async {
    try {
      final response = await myApiService.post(
        EndPoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok) {
        final json = response.data;

        // Determine the type of response and parse accordingly
        if (json['otp_verified'] == true && json.containsKey('access')) {
          // Handle normal login response
          UserManager().setUser(User.fromJson(json['user']));
          return Right(LoginResponseModel.fromJson(json));
        } else if (json['otp_verified'] == false &&
            json.containsKey('otp_success')) {
          // Handle OTP login response
          return Right(OTPResponseModel.fromJson(json));
        } else {
          return const Left('Unknown response format');
        }
      } else {
        return Left('Failed to login: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, Unit>> logout(String refreshToken) async {
    try {
      final response = await myApiService.post(
        EndPoints.logout,
        data: {
          'refresh': refreshToken,
        },
      );

      if (response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok) {
        final json = response.data;
        if (json['success'] == true) {
          UserManager().clearUser();
          return const Right(unit);
        } else {
          return const Left('Failed to log out: Server responded with failure');
        }
      } else {
        return Left('Failed to log out: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }
}
