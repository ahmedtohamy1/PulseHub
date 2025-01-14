import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../data/repos/manage_projects_repo.dart';

part 'manage_projects_state.dart';

@injectable
class ManageProjectsCubit extends Cubit<ManageProjectsState> {
  final ManageProjectsRepository _repository;
  ManageProjectsCubit(this._repository) : super(ManageProjectsInitial());
}
