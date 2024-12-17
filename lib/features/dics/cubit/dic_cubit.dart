import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/dics/data/models/dic_services_model.dart';
import 'package:pulsehub/features/dics/data/repos/dic_repo.dart';

part 'dic_state.dart';

@injectable
class DicCubit extends Cubit<DicState> {
  final DicRepository _repository;
  DicCubit(this._repository) : super(DicInitial());

  Future<void> getDic() async {
    emit(DicLoading());
    try {
      final token =
          await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
      final res = await _repository.getDics(
          token, UserManager().user!.userId.toString());
      res.fold(
        (failure) => emit(DicError(failure)),
        (response) => emit(DicSuccess(response)),
      );
    } catch (e) {
      emit(DicError(e.toString()));
    }
  }
}
