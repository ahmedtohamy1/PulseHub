import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/get_all_projects_response_model.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart'
    as owner;

import '../data/repos/manage_projects_repo.dart';

part 'manage_projects_state.dart';

@injectable
class ManageProjectsCubit extends Cubit<ManageProjectsState> {
  final ManageProjectsRepository _repository;
  GetAllProjectsResponseModel? _cachedProjects;
  List<owner.OwnerModel>? _cachedOwners;

  ManageProjectsCubit(this._repository) : super(ManageProjectsInitial());

  Future<void> getAllProjects() async {
    if (isClosed) {
      return;
    }

    // If we have cached data, emit it first
    if (_cachedProjects != null) {
      emit(GetAllProjectsSuccess(_cachedProjects!));
    } else {
      emit(GetAllProjectsLoading());
    }

    try {
      final token =
          await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
      final result = await _repository.getAllProjects(token);
      if (!isClosed) {
        result.fold(
          (error) => emit(GetAllProjectsFailure(error)),
          (projects) {
            _cachedProjects = projects;
            emit(GetAllProjectsSuccess(projects));
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(GetAllProjectsFailure(e.toString()));
      }
    }
  }

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

  Future<void> createProject(String title, int ownerId, XFile? picture,
      String? acronym, String? consultant, String? contractor) async {
    emit(CreateProjectLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final result = await _repository.createProject(
        token, title, ownerId, picture, acronym, consultant, contractor);

    result.fold(
      (error) => emit(CreateProjectFailure(error)),
      (success) {
        // Clear projects cache to force refresh
        _cachedProjects = null;
        emit(CreateProjectSuccess());
      },
    );
  }

  @override
  Future<void> close() {
    _cachedProjects = null;
    _cachedOwners = null;
    return super.close();
  }
}
