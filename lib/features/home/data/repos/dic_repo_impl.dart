import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/home/data/dic_services_model.dart';
import 'package:pulsehub/features/home/data/repos/dic_repo.dart';

@LazySingleton(as: DicRepository)
class DicRepoImpl implements DicRepository {
  final MyApi myApiService;
  DicRepoImpl(this.myApiService);

  @override
  Future<Either<String, DicServicesResponse>> getDics(
      String token, String userId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getDics,
        token: token,
        queryParameters: {
          'user_id': int.parse(userId),
        },
      );

      if ((response.statusCode == StatusCode.created ||
          (response.statusCode == StatusCode.ok &&
              response.data['success'] == true))) {
        final json = response.data;
        return Right(DicServicesResponse.fromJson(json));
      } else {
        final detail = response.data['detail']?.toString() ?? '';
        if (detail.contains('Given token not valid for any token type')) {
          return const Left('Token expired');
        } else {
          return Left('Failed to get sessions: ${response.statusCode}');
        }
      }
    } on DioException catch (dioError) {
      final response = dioError.response;
      if (response != null) {
        final detail = response.data['detail']?.toString() ?? '';
        if (detail.contains('Given token not valid for any token type')) {
          return const Left('Token expired');
        } else {
          return Left(
              'Failed with status code: ${response.statusCode}, message: ${response.data}');
        }
      }
      return Left('Network error occurred: ${dioError.message}');
    } catch (error) {
      return Left('Unexpected exception occurred: $error');
    }
  }
}
