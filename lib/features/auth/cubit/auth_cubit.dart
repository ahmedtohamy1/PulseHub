import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/auth/cubit/auth_state.dart';
import 'package:pulsehub/features/auth/data/models/login_response_model.dart';
import 'package:pulsehub/features/auth/data/models/otp_login_response.dart';
import 'package:pulsehub/features/auth/data/repositories/auth_repository.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  AuthCubit(this._authRepository) : super(AuthInitial());

  /// Handles login process, including OTP responses
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final res = await _authRepository.login(email, password);
      res.fold(
        // Failure case
        (failureMessage) => emit(AuthFailure(failureMessage)),

        // Success case
        (response) async {
          if (response is LoginResponseModel) {
            UserManager().setUser(response.user);
            // Normal login success
            emit(AuthSuccess());
          } else if (response is OTPResponseModel) {
            // OTP login success, emit the OTP message
            await SharedPrefHelper.setSecuredString(
                "otpAccess", response.otpAccess);
            emit(AuthOTP(response.otpMessage));
          } else {
            // Unknown success response
            emit(AuthFailure("Unknown response format."));
          }
        },
      );
    } catch (e) {
      emit(AuthFailure("An error occurred: $e"));
    }
  }

  Future sendPasswordResetCode(String email) async {
    emit(AuthOTPLoading());
    try {
      var res = await _authRepository.sendPasswordResetCode(email);
      res.fold(
        (failureMessage) => emit(AuthOTPFailure(failureMessage)),
        (response) {
          emit(AuthOTPSuccess());
        },
      );
    } catch (e) {
      emit(AuthFailure("An error occurred: $e"));
    }
  }

  Future verifyResetPasswordOTP(
      String email, String otp, String password, String confirmPassword) async {
    emit(AuthOTPLoading());
    try {
      var res = await _authRepository.verifyResetPasswordOTP(
          email, otp, password, confirmPassword);
      res.fold(
        (failureMessage) => emit(AuthOTPFailure(failureMessage)),
        (response) {
          emit(AuthOTPSuccess());
        },
      );
    } catch (e) {
      emit(AuthFailure("An error occurred: $e"));
    }
  }

  Future verifyLoginOTP(String otp, bool remeberMe) async {
    emit(AuthOTPLoading());
    try {
      final otpAccess = await SharedPrefHelper.getSecuredString("otpAccess");
      final res =
          await _authRepository.verifyLoginOTP(otp, otpAccess, remeberMe);
      res.fold(
        (failureMessage) => emit(AuthFailure(failureMessage)),
        (response) {
          UserManager().setUser(response.user);
          emit(AuthSuccess());
        },
      );
    } catch (e) {
      emit(AuthFailure("An error occurred: $e"));
    }
  }
}
