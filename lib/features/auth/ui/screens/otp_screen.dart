import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:pulsehub/core/helpers/auth_helper.dart';
import 'package:pulsehub/core/routing/routes.dart';
import 'package:pulsehub/features/auth/cubit/auth_cubit.dart';
import 'package:pulsehub/features/auth/cubit/auth_state.dart';

class VerifyOtpScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();

  VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                "Enter OTP",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
              endIndent: 60,
              indent: 60,
            ),
            const SizedBox(height: 16),
            Pinput(
              focusedPinTheme: PinTheme(
                width: 60,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(232, 235, 241, 0.37),
                  borderRadius: BorderRadius.circular(24),
                ),
              ).copyWith(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05999999865889549),
                      offset: Offset(0, 3),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
              separatorBuilder: (index) => const SizedBox(width: 16),
              defaultPinTheme: PinTheme(
                width: 60,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(232, 235, 241, 0.37),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              cursor: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 21,
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(137, 146, 160, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              controller: otpController,
              length: 6,
              validator: (pin) => pin!.length == 6 ? null : 'Invalid OTP',
            ),
            const SizedBox(height: 16),
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  authenticate().then((authenticated) {
                    if (authenticated) {
                      context.go(Routes.dicScreen);
                    }
                  });
                }
                if (state is AuthOTPSuccess) {
                  Fluttertoast.showToast(
                    msg: 'OTP Verified Successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                } else if (state is AuthOTPFailure) {
                  Fluttertoast.showToast(
                    msg: 'OTP Verification Failed',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context
                              .read<AuthCubit>()
                              .verifyLoginOTP(otpController.text, true);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: state is AuthOTPLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Verify OTP"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Navigate back to login
                      },
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
