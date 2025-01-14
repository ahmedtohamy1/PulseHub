import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/features/manage/data/repos/manage_repo.dart';

part 'manage_state.dart';

@injectable
class ManageCubit extends Cubit<ManageState> {
  final ManageRepository _repository;
  ManageCubit(this._repository) : super(ManageInitial());
}
