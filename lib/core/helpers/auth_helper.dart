import 'package:local_auth/local_auth.dart';

final localAuth = LocalAuthentication();

Future<bool> authenticate() async {
  bool authenticated = false;
  try {
    authenticated = await localAuth.authenticate(
      localizedReason: 'Scan your fingerprint to access',
    );
  } catch (e) {
    rethrow;
  }
  return authenticated;
}
