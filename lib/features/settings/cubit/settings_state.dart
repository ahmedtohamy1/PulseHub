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

final class DeleteSessionSuccess extends SettingsState {
  final String message;
  const DeleteSessionSuccess(this.message);
}

final class DeleteSessionError extends SettingsState {
  final String message;
  const DeleteSessionError(this.message);
}

final class UpdateProfileLoading extends SettingsState {}

final class UpdateProfileSuccess extends SettingsState {
  final String message;
  const UpdateProfileSuccess(this.message);
}

final class UpdateProfileError extends SettingsState {
  final String message;
  const UpdateProfileError(this.message);
}

final class UserDetailsSuccess extends SettingsState {
  final UserDetails userDetails;
  const UserDetailsSuccess(this.userDetails);
}

final class UserDetailsError extends SettingsState {
  final String message;
  const UserDetailsError(this.message);
}

final class UserDetailsLoading extends SettingsState {}

final class LogoutLoading extends SettingsState {}

final class LogoutSuccess extends SettingsState {}

final class LogoutError extends SettingsState {
  final String message;
  const LogoutError(this.message);
}

final class ResetPasswordLoading extends SettingsState {}

final class ResetPasswordSuccess extends SettingsState {}

final class ResetPasswordError extends SettingsState {
  final String message;
  const ResetPasswordError(this.message);
}

final class GetNotificationsLoading extends SettingsState {}

final class GetNotificationsSuccess extends SettingsState {
  final GetNotificationResponseModel response;
  const GetNotificationsSuccess(this.response);
}

final class GetNotificationsError extends SettingsState {
  final String message;
  const GetNotificationsError(this.message);
}
