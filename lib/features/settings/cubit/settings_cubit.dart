import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/settings/data/models/manage_session_response.dart';
import 'package:pulsehub/features/settings/data/models/user_details.dart';
import 'package:pulsehub/features/settings/data/repos/settings_repo.dart';

part 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;
  SettingsCubit(this._repository) : super(SettingsInitial());

  Future<void> getSessions() async {
    emit(SettingsInitial());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getSettions(token);
    res.fold(
      (failure) => emit(SessionsError(failure)),
      (response) => emit(SessionsSuccess(response)),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    emit(SettingsInitial());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.deleteSession(token, sessionId);
    res.fold(
      (failure) => emit(SessionsError(failure)),
      (message) => emit(DeleteSessionSuccess(message)),
    );
  }

  UserDetails? userDetails;
  Future<void> getUserDetails() async {
    emit(UserDetailsLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getUserDetails(token);
    res.fold(
      (failure) => emit(UserDetailsError(failure)),
      (userDetails) {
        this.userDetails = userDetails;
        emit(UserDetailsSuccess(userDetails));
      },
    );
  }

  Future<void> updateProfile(
    String email,
    String firstName,
    String lastName,
    String title,
    String picture,
    String mode,
  ) async {
    emit(UpdateProfileLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.updateUserDetails(
      token,
      email,
      firstName,
      lastName,
      title,
      picture,
      mode,
    );
    res.fold(
      (failure) => emit(UpdateProfileError(failure)),
      (message) => emit(UpdateProfileSuccess(message)),
    );
  }
}
