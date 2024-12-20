import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/ai_report/data/models/ai_response.dart';

abstract class AiReportRepository {
  Future<Either<String, ResponseModel>> generateAnswer(
      String token,
      String question,
      int numberOfReferences,
      bool useKnowledgeBase,
      String selectedModel);
}
