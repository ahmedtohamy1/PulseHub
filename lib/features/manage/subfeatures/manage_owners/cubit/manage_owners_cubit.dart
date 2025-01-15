import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_owners/data/repos/manage_owners_repo.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart';

part 'manage_owners_state.dart';

@injectable
class ManageOwnersCubit extends Cubit<ManageOwnersState> {
  final ManageOwnersRepository _repository;
  List<OwnerModel>? _cachedOwners;

  ManageOwnersCubit(this._repository) : super(ManageOwnersInitial());

  Future<void> getAllOwners() async {
    if (isClosed) {
      return;
    }

    // If we have cached data, emit it first
    if (_cachedOwners != null) {
      emit(GetAllOwnersSuccess(_cachedOwners!));
    } else {
      emit(GetAllOwnersLoading());
    }

    try {
      final token =
          await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
      if (token.isEmpty) {
        if (!isClosed) {
          emit(const GetAllOwnersFailure('Authentication token not found'));
        }
        return;
      }

      final result = await _repository.getAllOwners(token);
      if (!isClosed) {
        result.fold(
          (error) {
            emit(GetAllOwnersFailure(error));
          },
          (owners) {
            _cachedOwners = owners;
            emit(GetAllOwnersSuccess(owners));
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(GetAllOwnersFailure(e.toString()));
      }
    }
  }

 /*  Future<void> deleteOwner(int ownerId) async {
    emit(DeleteOwnerLoading(ownerId));
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repository.deleteOwner(token, ownerId);

    result.fold(
      (error) => emit(DeleteOwnerFailure(error)),
      (success) async {
        emit(DeleteOwnerSuccess());
        // Refresh owners list after successful deletion
        await getAllOwners();
      },
    );
  }
 */
  @override
  Future<void> close() {
    _cachedOwners = null;
    return super.close();
  }
}
