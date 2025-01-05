import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/ai_report/data/ai_report_repo.dart';
import 'package:pulsehub/features/ai_report/data/models/ai_response.dart';

part 'ai_report_state.dart';

@injectable
class AiReportCubit extends Cubit<AiReportState> {
  final AiReportRepository _aiReportRepository;
  AiReportCubit(this._aiReportRepository) : super(AiReportInitial());

  void generateAnswer(String question, int numberOfReferences,
      bool useKnowledgeBase, String selectedModel) async {
    emit(AiReportLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _aiReportRepository.generateAnswer(
        token, question, numberOfReferences, useKnowledgeBase, selectedModel);
    res.fold((l) => emit(AiReportFailure(l)), (r) => emit(AiReportSuccess(r)));
  }
}
