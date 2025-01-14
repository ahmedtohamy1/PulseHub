import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../data/repos/manage_users_repo.dart';

part 'manage_users_state.dart';

@injectable
class ManageUsersCubit extends Cubit<ManageUsersState> {
  final ManageUsersRepository _repository;
  ManageUsersCubit(this._repository) : super(ManageUsersInitial());
}
