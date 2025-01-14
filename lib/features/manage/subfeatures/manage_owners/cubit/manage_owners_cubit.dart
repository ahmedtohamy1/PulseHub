import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../data/repos/manage_owners_repo.dart';

part 'manage_owners_state.dart';

@injectable
class ManageOwnersCubit extends Cubit<ManageOwnersState> {
  final ManageOwnersRepository _repository;
  ManageOwnersCubit(this._repository) : super(ManageOwnersInitial());
}
