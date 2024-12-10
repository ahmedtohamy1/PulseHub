import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/theming/app_styles.dart';
import 'package:pulsehub/features/auth/cubit/auth_cubit.dart';
import 'package:pulsehub/features/auth/cubit/auth_state.dart';
import 'package:pulsehub/features/auth/ui/widgets/save_button.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Login here",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Welcome back, you've been missed!",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 100),
              TextField(
                controller: emailController,
                decoration: customInputDecoration("Email", Icons.email, true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: customInputDecoration("Password", Icons.lock, true),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _showForgotPasswordModal(context);
                  },
                  child: const Text(
                    "Forgot your password?",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SaveButton(
                  emailController: emailController,
                  passwordController: passwordController),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordModal(BuildContext context) {
    final emailController = TextEditingController();
    final otpController = TextEditingController();
    final passwordController = TextEditingController(); // New password field
    final confirmPasswordController =
        TextEditingController(); // New confirm password field

    WoltModalSheet.show(
      modalDecorator: (child) {
        return BlocProvider(
          create: (context) => sl<AuthCubit>(),
          child: child,
        );
      },
      context: context,
      pageListBuilder: (modalSheetContext) => [
        // Page 1: Email Input
        WoltModalSheetPage(
          useSafeArea: true,
          pageTitle: const Center(
              child: Text("Forgot Password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                  endIndent: 60,
                  indent: 60,
                ),
                TextField(
                  controller: emailController,
                  decoration: customInputDecoration("Email", Icons.email, true),
                ),
                const SizedBox(height: 16),
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthOTPSuccess) {
                      WoltModalSheet.of(modalSheetContext).showNext();
                    } else if (state is AuthOTPFailure) {
                      Fluttertoast.showToast(
                        msg: state.message,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  builder: (context, state) {
                    return state is AuthOTPLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<AuthCubit>().sendPasswordResetCode(
                                    emailController.text);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text("Send OTP"),
                            ),
                          );
                  },
                )
              ],
            ),
          ),
        ),

        // Page 2: OTP Input + New Password
        WoltModalSheetPage(
          useSafeArea: true,
          pageTitle: const Center(
            child: Text(
              "Enter OTP and Reset Password",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                  endIndent: 60,
                  indent: 60,
                ),
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
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: customInputDecoration(
                      "New Password", Icons.lock_outline, true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: customInputDecoration(
                      "Confirm Password", Icons.lock_outline, true),
                ),
                const SizedBox(height: 16),
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthOTPSuccess) {
                      Fluttertoast.showToast(
                        msg: "Password reset successful!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.pop(context);
                    } else if (state is AuthOTPFailure) {
                      Fluttertoast.showToast(
                        msg: "Password reset Failed, try again later.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  builder: (context, state) {
                    return state is AuthOTPLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Implement your logic to verify OTP and reset password
                                context
                                    .read<AuthCubit>()
                                    .verifyResetPasswordOTP(
                                      emailController.text,
                                      otpController.text,
                                      passwordController.text,
                                      confirmPasswordController.text,
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child:
                                  const Text("Verify OTP and Reset Password"),
                            ),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
