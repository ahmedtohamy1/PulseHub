import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../data/repos/manage_sensors_repo.dart';

part 'manage_sensors_state.dart';

@injectable
class ManageSensorsCubit extends Cubit<ManageSensorsState> {
  final ManageSensorsRepository _repository;
  ManageSensorsCubit(this._repository) : super(ManageSensorsInitial());
}
