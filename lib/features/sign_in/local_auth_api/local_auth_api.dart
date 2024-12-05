import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on Exception catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
          //providing the reason is not clean UI but setting this to "" throws assertion error
          localizedReason: 'Provide biometrics to continue.',
          options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
              sensitiveTransaction: true));
    } on PlatformException catch (_) {
      return false;
    }
  }
}
