import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/auth/data/models/login_response_model.dart';
import 'package:pulsehub/features/auth/data/models/otp_login_response.dart';
import 'package:pulsehub/features/auth/data/models/otp_verify.dart';
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
        options: {
          'headers': {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          'withCredentials': true,
        },
      );

      if (response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok) {
        final json = response.data;

        // Determine the type of response and parse accordingly
        if (json['otp_verified'] == true && json.containsKey('access')) {
          // Handle normal login response
          UserManager().setUser(User.fromJson(json['user']));
          await SharedPrefHelper.setSecuredString(
              SharedPrefKeys.token, json['access']);

          // Store cookies from response only on successful login
          final cookies = response.headers['set-cookie'];
          if (cookies != null && cookies is List) {
            final cookieList = List<String>.from(cookies);
            await SharedPrefHelper.cookieSave(cookieList);
          }

          // Store CSRF token if present
          final csrfTokenHeader = response.headers['x-csrftoken'];
          if (csrfTokenHeader != null) {
            final csrfToken = csrfTokenHeader is List
                ? csrfTokenHeader.first
                : csrfTokenHeader.toString();
            if (csrfToken.isNotEmpty) {
              await SharedPrefHelper.setSecuredString(
                  SharedPrefKeys.csrfToken, csrfToken);
            }
          }

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
  Future sendPasswordResetCode(String email) async {
    try {
      final response = await myApiService.get(
        EndPoints.sendPasswordResetCode,
        queryParameters: {
          'email': email,
        },
        options: {
          'headers': {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          'withCredentials': true,
        },
      );

      if (response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok) {
        final json = response.data;
        if (json['password_reset_code_success'] == true) {
          return const Right(unit);
        } else {
          return const Left(
              'Failed to send code: Server responded with failure');
        }
      } else {
        return Left('Failed to log out: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future verifyResetPasswordOTP(
      String email, String otp, String password, String confirmPassword) async {
    try {
      final response = await myApiService.post(
        EndPoints.sendPasswordResetCode,
        data: {
          'email': email,
          'password_reset_code': otp,
          'new_password': password,
          'confirm_new_password': confirmPassword,
        },
        options: {
          'headers': {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          'withCredentials': true,
        },
      );

      if (response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok) {
        final json = response.data;
        if (json['success'] == true) {
          return const Right(unit);
        } else {
          return const Left(
              'Failed to send code: Server responded with failure');
        }
      } else {
        return Left('Failed to log out: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, OtpVerify>> verifyLoginOTP(
      String otp, String otpAccess, bool remeberMe) async {
    try {
      final response = await myApiService.post(
        EndPoints.verifyLoginOTP,
        data: {
          "otp": otp,
          "otp_access": otpAccess,
          "remember_me": remeberMe,
        },
        options: {
          'headers': {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          'withCredentials': true,
        },
      );

      if (response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok) {
        final json = response.data;
        if (json['success'] == true) {
          await SharedPrefHelper.setSecuredString(
              SharedPrefKeys.token, json['access']);
          await SharedPrefHelper.setSecuredString(
              SharedPrefKeys.refreshToken, json['refresh']);

          // Store cookies from response only on successful OTP verification
          final cookies = response.headers['set-cookie'];
          if (cookies != null && cookies is List) {
            final cookieList = List<String>.from(cookies);
            await SharedPrefHelper.cookieSave(cookieList);
          }

          // Store CSRF token if present
          final csrfTokenHeader = response.headers['x-csrftoken'];
          if (csrfTokenHeader != null) {
            final csrfToken = csrfTokenHeader is List
                ? csrfTokenHeader.first
                : csrfTokenHeader.toString();
            if (csrfToken.isNotEmpty) {
              await SharedPrefHelper.setSecuredString(
                  SharedPrefKeys.csrfToken, csrfToken);
            }
          }

          return Right(OtpVerify.fromJson(json));
        } else {
          return const Left(
              'Failed to verify code: Server responded with failure');
        }
      } else {
        return Left('Failed to verify code: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }
}
