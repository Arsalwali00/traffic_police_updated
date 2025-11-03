import 'package:GBPayUsers/core/api_service.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/features/auth/model/login_model.dart';
import 'package:GBPayUsers/config/api.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(LoginModel user) async {
    try {
      final response = await ApiService.post(
        API.login,
        user.toJson(),
        withAuth: false,
      );

      print("🔹 API Login Response: $response");

      if (response['success'] == true && response.containsKey('data')) {
        final responseData = response['data'];

        if (responseData['status'] == true) {
          final userData = responseData['data'];

          await LocalStorage.saveToken(responseData['token']);
          await LocalStorage.saveUser(userData);

          return {
            'success': true,
            'message': responseData['message'] ?? "Login successful",
            'token': responseData['token'],
            'user': userData,
          };
        }
      }

      // ✅ Handle error directly from response['message']
      return {
        'success': false,
        'message': response['message'] ?? "An error occurred during login.",
      };
    } catch (e) {
      print("❌ AuthService: Login Error - $e");
      return {'success': false, 'message': "A network error occurred. Try again."};
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      String? token = await LocalStorage.getToken();
      print("🔹 Checking login status. Token found: $token");
      return token != null && token.isNotEmpty;
    } catch (e) {
      print("❌ AuthService: isLoggedIn Error - $e");
      return false;
    }
  }

  static Future<bool> logout() async {
    try {
      final response = await ApiService.post(API.logout, {}, withAuth: true);
      print("🔹 Logout API Response: $response");

      if (response['success'] == true) {
        await LocalStorage.logout();
        String? tokenCheck = await LocalStorage.getToken();
        print("🔹 Token after logout: $tokenCheck");

        if (tokenCheck == null || tokenCheck.isEmpty) {
          print("✅ Logout successful & token cleared!");
          return true;
        } else {
          print("❌ Token was not removed properly!");
          return false;
        }
      }

      print("❌ Logout API failed: ${response['message']}");
      return false;
    } catch (e) {
      print("❌ AuthService: Logout Error - $e");
      return false;
    }
  }
}