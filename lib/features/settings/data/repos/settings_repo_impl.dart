import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/settings/data/models/manage_session_response.dart';
import 'package:pulsehub/features/settings/data/models/user_details.dart';
import 'package:pulsehub/features/settings/data/repos/settings_repo.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepoImpl extends SettingsRepository {
  final MyApi myApiService;
  SettingsRepoImpl(this.myApiService);

  @override
  Future<Either<String, ManageSessionResponse>> getSettions(
      String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.activeSessions,
        token: token,
      );

      if (response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok) {
        final json = response.data;

        if (json['success'] == true) {
          return Right(ManageSessionResponse.fromJson(json));
        } else {
          return const Left('Unknown response format');
        }
      } else {
        return Left('Failed to get sessions: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, String>> deleteSession(
      String token, String sessionId) async {
    try {
      final response = await myApiService
          .delete(EndPoints.activeSessions, token: token, queryParameters: {
        'id': sessionId,
      });

      if (response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok) {
        final json = response.data;

        if (json['success'] == true) {
          return Right(json['message']);
        } else {
          return const Left('Unknown response format');
        }
      } else {
        return Left('Failed to get sessions: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, UserDetails>> getUserDetails(String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.userDetails,
        token: token,
      );

      if (response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok) {
        final json = response.data;

        return Right(UserDetails.fromJson(json));
      } else {
        return Left('Failed to get sessions: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, String>> updateUserDetails(
    String token,
    String email,
    String firstName,
    String lastName,
    String title,
    String picture,
    String mode,
  ) async {
    try {
      final response = await myApiService.post(
        EndPoints.userDetails,
        token: token,
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'title': title,
          'picture': picture,
          'mode': mode,
        },
      );
      if ((response.statusCode == StatusCode.created ||
          response.statusCode == StatusCode.ok &&
              response.data['success'] == true)) {
        final json = response.data;

        return Right(json['message']);
      } else {
        return Left('Failed to get sessions: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }
}
