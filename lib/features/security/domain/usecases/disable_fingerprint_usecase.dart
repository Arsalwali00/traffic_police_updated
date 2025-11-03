import 'package:GBPayUsers/features/security/data/repositories/security_repository.dart';

class DisableFingerprintUseCase {
  /// ✅ **Disable Fingerprint Login**
  Future<void> execute() async {
    await SecurityRepository.disableBiometricLogin();
  }
}
