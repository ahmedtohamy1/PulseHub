import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/project_dashboard/subfeatures/visualise/data/visualise_repo.dart';

part 'visualise_state.dart';

@injectable
class VisualiseCubit extends Cubit<VisualiseState> {
  final VisualiseRepo visualiseRepo;
  VisualiseCubit(this.visualiseRepo) : super(VisualiseInitial());

  Future<void> saveImageWithSensor(
      int dashboardId,
      String componentName,
      String imageName,
      List<Map<String, Map<String, dynamic>>> sensorsIdsAndCoordinates) async {
    emit(VisualiseLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);

    final result = await visualiseRepo.saveImageWithSensor(
        token, dashboardId, componentName, imageName, sensorsIdsAndCoordinates);
    result.fold(
      (l) => emit(VisualiseFailure(l)),
      (r) => emit(VisualiseSuccess()),
    );
  }
}
