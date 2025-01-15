import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_sensors/data/models/get_all_sensor_types_response_model.dart';

import '../data/repos/manage_sensors_repo.dart';

part 'manage_sensors_state.dart';

@injectable
class ManageSensorsCubit extends Cubit<ManageSensorsState> {
  final ManageSensorsRepository _repository;
  ManageSensorsCubit(this._repository) : super(ManageSensorsInitial());

  Future<void> getAllSensorTypes() async {
    emit(ManageSensorsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repository.getAllSensorTypes(token);
    result.fold(
      (l) => emit(ManageSensorsError(l)),
      (r) => emit(ManageSensorsLoaded(r)),
    );
  }
}
