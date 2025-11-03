import 'package:local_auth/local_auth.dart';
import 'package:GBPayUsers/features/security/data/repositories/security_repository.dart';

class EnableFingerprintUseCase {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// ✅ **Check if Device Supports Biometrics Properly**
  Future<bool> isBiometricAvailable() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      print("📌 Debug: canCheckBiometrics = $canCheck, isDeviceSupported = $isDeviceSupported, availableBiometrics = $availableBiometrics");

      return canCheck && availableBiometrics.isNotEmpty;
    } catch (e) {
      print("❌ Error checking biometric availability: $e");
      return false;
    }
  }

  /// ✅ **Trigger Biometric Authentication**
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Use your fingerprint to login securely',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print("❌ Biometric Authentication Failed: $e");
      return false;
    }
  }

  /// ✅ **Enable Biometric Login After Authentication**
  Future<void> enableBiometricLogin() async {
    bool isSupported = await isBiometricAvailable();
    if (!isSupported) {
      print("❌ Biometric login not supported on this device.");
      return;
    }

    bool authenticated = await authenticate();
    if (authenticated) {
      await SecurityRepository.saveBiometricPreference(true);
      print("✅ Fingerprint login enabled successfully.");
    } else {
      print("⚠️ Fingerprint authentication was not successful. Login not enabled.");
    }
  }
}
