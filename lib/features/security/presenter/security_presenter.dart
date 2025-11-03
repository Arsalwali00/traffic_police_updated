import 'package:GBPayUsers/features/security/data/repositories/security_repository.dart';
import 'package:GBPayUsers/features/security/domain/usecases/enable_fingerprint_usecase.dart';
import 'package:GBPayUsers/features/security/domain/usecases/disable_fingerprint_usecase.dart';

class SecurityPresenter {
  final EnableFingerprintUseCase _enableFingerprintUseCase = EnableFingerprintUseCase();
  final DisableFingerprintUseCase _disableFingerprintUseCase = DisableFingerprintUseCase();

  /// ✅ **Check if Fingerprint Login is Enabled**
  Future<bool> isFingerprintEnabled() async {
    return await SecurityRepository.isBiometricEnabled();
  }

  /// ✅ **Enable Fingerprint Login**
  Future<void> enableFingerprint() async {
    await _enableFingerprintUseCase.enableBiometricLogin();
  }

  /// ✅ **Disable Fingerprint Login**
  Future<void> disableFingerprint() async {
    await _disableFingerprintUseCase.execute();
  }
}
