part of 'settings_cubit.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

final class SettingsInitial extends SettingsState {}

final class SessionsSuccess extends SettingsState {
  final ManageSessionResponse response;
  const SessionsSuccess(this.response);
}

final class SessionsError extends SettingsState {
  final String message;
  const SessionsError(this.message);
}
