import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _keyHasSavedLogin = 'has_saved_login';
  static const String _keyLastRole = 'last_login_role';
  static const String _keyLastWorkerName = 'last_worker_name';

  /// Check if the user has previously logged in with username and password
  static Future<bool> hasSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSavedLogin) ?? false;
  }

  /// Save the role and worker name of the user who successfully logged in
  static Future<void> saveSuccessfulLogin({
    required String role,
    String workerName = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSavedLogin, true);
    await prefs.setString(_keyLastRole, role);
    await prefs.setString(_keyLastWorkerName, workerName);
  }

  /// Legacy helper for compatibility
  static Future<void> saveLastLoginRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSavedLogin, true);
    await prefs.setString(_keyLastRole, role);
  }

  /// Get the last logged in role ('admin' or 'worker')
  static Future<String?> getLastLoginRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastRole);
  }

  /// Get the last logged in worker's name
  static Future<String?> getLastWorkerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastWorkerName);
  }

  /// Checks if the device has biometric capabilities
  static Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the actual phone fingerprint / biometric authentication
  static Future<bool> authenticateWithFingerprint() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to sign in to Egy Tech',
        biometricOnly: false,
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
