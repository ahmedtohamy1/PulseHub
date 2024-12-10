import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
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
        (response) {
          if (response is LoginResponseModel) {
            // Normal login success
            emit(AuthSuccess());
          } else if (response is OTPResponseModel) {
            // OTP login success, emit the OTP message
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
}
