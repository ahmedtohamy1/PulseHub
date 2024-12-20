import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/ai_report/data/ai_report_repo.dart';
import 'package:pulsehub/features/ai_report/data/models/ai_response.dart';

@LazySingleton(as: AiReportRepository)
class AiReportRepositoryImpl implements AiReportRepository {
  final MyApi myApiService;
  AiReportRepositoryImpl(this.myApiService);
  @override
  Future<Either<String, ResponseModel>> generateAnswer(
      String token,
      String question,
      int numberOfReferences,
      bool useKnowledgeBase,
      String selectedModel) async {
    try {
      final response = await myApiService.post(
        EndPoints.aiQuestion,
        token: token,
        data: {
          'question': question,
          'k': numberOfReferences,
          'rag': useKnowledgeBase,
          'model': selectedModel,
        },
      );

      if ((response.statusCode == StatusCode.created ||
          (response.statusCode == StatusCode.ok &&
              response.data['success'] == true))) {
        final json = response.data;
        return Right(ResponseModel.fromJson(json));
      } else {
        final detail = response.data['detail']?.toString() ?? '';
        if (detail.contains('Given token not valid for any token type')) {
          return const Left('Token expired');
        } else {
          return Left('Failed to get reponse : ${response.statusCode}');
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
