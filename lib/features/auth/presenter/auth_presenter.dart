import 'package:GBPayUsers/core/auth_service.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/features/auth/model/login_model.dart';

class AuthPresenter {
  /// ✅ **User Login (Supports Email or Phone)**
  Future<Map<String, dynamic>> login(LoginModel user, {required bool rememberMe}) async {
    try {
      final response = await AuthService.login(user);

      print("🔹 AuthPresenter Login Response: ${response.toString()}"); // Debugging

      if (response['success'] == true) {
        if (rememberMe) {
          await LocalStorage.saveToken(response['token']);
          await LocalStorage.saveUser(response['user']);
        }

        return {'success': true, 'message': response['message'] ?? "Login successful!"};
      }

      return {'success': false, 'message': response['message'] ?? "Invalid login credentials."};
    } catch (e) {
      print("❌ AuthPresenter: Login Error - $e");
      return {'success': false, 'message': "An unexpected error occurred. Try again."};
    }
  }

  /// ✅ **Check if User is Logged In**
  Future<bool> isLoggedIn() async {
    try {
      String? token = await LocalStorage.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print("❌ AuthPresenter: isLoggedIn Error - $e");
      return false;
    }
  }

  /// ✅ **Logout (Clears Token & User Data)**
  Future<void> logout() async {
    try {
      await LocalStorage.logout();
    } catch (e) {
      print("❌ AuthPresenter: Logout Error - $e");
    }
  }
}
