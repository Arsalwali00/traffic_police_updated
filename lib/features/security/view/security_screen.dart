import 'package:flutter/material.dart';
import 'package:GBPayUsers/features/security/presenter/security_presenter.dart';
import 'package:GBPayUsers/features/security/domain/usecases/enable_fingerprint_usecase.dart';

class SecurityScreen extends StatefulWidget {
  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final SecurityPresenter _presenter = SecurityPresenter();
  final EnableFingerprintUseCase _fingerprintUseCase = EnableFingerprintUseCase();

  bool _isBiometricEnabled = false;
  bool _isBiometricSupported = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// ✅ **Load Biometric Status & Check Support**
  Future<void> _loadSecuritySettings() async {
    bool isSupported = await _fingerprintUseCase.isBiometricAvailable();
    bool isEnabled = await _presenter.isFingerprintEnabled();

    if (mounted) {
      setState(() {
        _isBiometricSupported = isSupported;
        _isBiometricEnabled = isEnabled;
        _isLoading = false;
      });
    }
  }

  /// ✅ **Enable/Disable Fingerprint Login**
  Future<void> _toggleBiometric(bool value) async {
    setState(() => _isLoading = true);

    if (value) {
      await _presenter.enableFingerprint();
    } else {
      await _presenter.disableFingerprint();
    }

    _loadSecuritySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // ✅ Dark mode
      appBar: AppBar(
        title: const Text("Security Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // ✅ Dark mode
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white)) // ✅ White loading indicator
          : Column(
        children: [
          if (_isBiometricSupported)
            Card(
              color: Colors.grey.shade900, // ✅ Dark grey card
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: const Text("Enable Fingerprint Login", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Use your fingerprint for quick login", style: TextStyle(color: Colors.white70)),
                trailing: Switch(
                  value: _isBiometricEnabled,
                  onChanged: _toggleBiometric,
                  activeColor: Colors.amber.shade700, // ✅ Amber switch
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fingerprint, size: 50, color: Colors.white70), // ✅ Fingerprint icon
                  const SizedBox(height: 10),
                  const Text(
                    "Fingerprint authentication is not supported on this device.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Try updating your device settings.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.amber.shade700), // ✅ Amber hint text
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
