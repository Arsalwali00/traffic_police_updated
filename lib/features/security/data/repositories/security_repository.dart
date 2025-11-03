import 'package:GBPayUsers/core/local_storage.dart';

class SecurityRepository {
  /// ✅ **Save Biometric Login Preference**
  static Future<void> saveBiometricPreference(bool enabled) async {
    await LocalStorage.setBool("use_fingerprint", enabled);
  }

  /// ✅ **Check if Biometric Login is Enabled**
  static Future<bool> isBiometricEnabled() async {
    return await LocalStorage.getBool("use_fingerprint") ?? false;
  }

  /// ✅ **Disable Biometric Login**
  static Future<void> disableBiometricLogin() async {
    await LocalStorage.remove("use_fingerprint");
  }
}
