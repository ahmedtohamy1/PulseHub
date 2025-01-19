import 'package:local_auth/local_auth.dart';

final localAuth = LocalAuthentication();

Future<bool> authenticate() async {
  try {
    // Check if device has biometrics
    final canAuthenticateWithBiometrics = await localAuth.canCheckBiometrics;
    final canAuthenticate = await localAuth.isDeviceSupported();

    // If device doesn't support biometrics or local auth, return true
    if (!canAuthenticateWithBiometrics || !canAuthenticate) {
      return true;
    }

    // Proceed with authentication if supported
    return await localAuth.authenticate(
      localizedReason: 'Scan your fingerprint to access',
    );
  } catch (e) {
    rethrow;
  }
}
