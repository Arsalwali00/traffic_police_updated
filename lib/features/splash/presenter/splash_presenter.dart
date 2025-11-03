import 'package:GBPayUsers/core/local_storage.dart';

class SplashPresenter {
  /// ✅ **Check Authentication Status Properly**
  Future<bool> checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating API delay

    /// ✅ **Check if Token Exists**
    bool isAuthenticated = await LocalStorage.hasToken();

    return isAuthenticated;
  }
}
