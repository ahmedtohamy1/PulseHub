import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> createOwner(String name, String? phone, String? address,
      String? city, String? country, XFile? logo) async {
    emit(CreateOwnerLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repository.createOwner(
        token, name, phone, address, city, country, logo);

    result.fold(
      (error) => emit(CreateOwnerFailure(error)),
      (success) {
        // Clear owners cache to force refresh
        _cachedOwners = null;
        emit(CreateOwnerSuccess());
      },
    );
  }

  Future<void> deleteOwner(int ownerId) async {
    emit(DeleteOwnerLoading(ownerId));
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repository.deleteOwner(token, ownerId);

    result.fold(
      (error) => emit(DeleteOwnerFailure(error)),
      (success) {
        _cachedOwners = null;
        emit(DeleteOwnerSuccess());
      },
    );
  }

  Future<void> updateOwner(int ownerId, String name, String? phone,
      String? address, String? country, XFile? logo, String? website) async {
    emit(UpdateOwnerLoading(ownerId));
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repository.updateOwner(
        token, ownerId, name, phone, address, country, logo, website);

    result.fold(
      (error) => emit(UpdateOwnerFailure(error)),
      (success) {
        _cachedOwners = null;
        emit(UpdateOwnerSuccess());
      },
    );
  }

  @override
  Future<void> close() {
    _cachedOwners = null;
    return super.close();
  }
}
