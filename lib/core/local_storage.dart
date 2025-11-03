import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static SharedPreferences? _preferences;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// ✅ **Initialize SharedPreferences (Called Internally)**
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  /// ✅ **Ensure `_preferences` is initialized before accessing it**
  static Future<void> _ensureInitialized() async {
    if (_preferences == null) {
      await init();
    }
  }

  /// ✅ **Save Boolean Value**
  static Future<void> setBool(String key, bool value) async {
    await _ensureInitialized();
    try {
      await _preferences?.setBool(key, value);
    } catch (e) {
      print("❌ LocalStorage: Error saving boolean - $e");
    }
  }

  /// ✅ **Get Boolean Value**
  static Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    try {
      return _preferences?.getBool(key);
    } catch (e) {
      print("❌ LocalStorage: Error retrieving boolean - $e");
      return null;
    }
  }

  /// ✅ **Remove a Specific Key**
  static Future<void> remove(String key) async {
    await _ensureInitialized();
    try {
      await _preferences?.remove(key);
    } catch (e) {
      print("❌ LocalStorage: Error removing key '$key' - $e");
    }
  }

  /// ✅ **Save Token Securely**
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'token', value: token);
      print("✅ Token saved successfully.");
    } catch (e) {
      print("❌ LocalStorage: Error saving token - $e");
    }
  }

  /// ✅ **Get Token Securely**
  static Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'token');
    } catch (e) {
      print("❌ LocalStorage: Error retrieving token - $e");
      return null;
    }
  }

  /// ✅ **Check if Token Exists**
  static Future<bool> hasToken() async {
    try {
      String? token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print("❌ LocalStorage: Error checking token - $e");
      return false;
    }
  }

  /// ✅ **Save User Data during Login (Stored as JSON String)**
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _ensureInitialized();
    try {
      await _preferences?.setString('user', jsonEncode(user));
      print("✅ User data saved successfully during login.");
    } catch (e) {
      print("❌ LocalStorage: Error saving user data during login - $e");
    }
  }

  /// ✅ **Update User Data from Edit Profile (Stored as JSON String)**
  static Future<void> updateUser(Map<String, dynamic> updatedFields) async {
    await _ensureInitialized();
    try {
      Map<String, dynamic>? currentUser = await getUser();
      if (currentUser != null) {
        currentUser.addAll(updatedFields); // Merge updated fields with existing data
        await _preferences?.setString('user', jsonEncode(currentUser));
        print("✅ User data updated successfully from edit profile.");
      } else {
        print("❌ No existing user data found to update.");
      }
    } catch (e) {
      print("❌ LocalStorage: Error updating user data from edit profile - $e");
    }
  }

  /// ✅ **Get User Data (Handles JSON Parsing Errors)**
  static Future<Map<String, dynamic>?> getUser() async {
    await _ensureInitialized();
    try {
      String? jsonUser = _preferences?.getString('user');
      return jsonUser != null ? jsonDecode(jsonUser) as Map<String, dynamic> : null;
    } catch (e) {
      print("❌ LocalStorage: Error parsing user data - $e");
      return null;
    }
  }

  /// ✅ **Logout: Remove Token and User Data (Ensuring Proper Deletion)**
  static Future<void> logout() async {
    try {
      print("🔹 Attempting logout...");

      await _secureStorage.delete(key: 'token');
      await _preferences?.remove('user');

      // ✅ Verify Token Removal
      String? tokenCheck = await getToken();
      if (tokenCheck == null || tokenCheck.isEmpty) {
        print("✅ Token successfully removed during logout.");
      } else {
        print("❌ Token was NOT removed properly!");
      }

      // ✅ Verify User Data Removal
      Map<String, dynamic>? userCheck = await getUser();
      if (userCheck == null) {
        print("✅ User data successfully removed.");
      } else {
        print("❌ User data was NOT removed properly!");
      }

    } catch (e) {
      print("❌ LocalStorage: Error during logout - $e");
    }
  }

  /// ✅ **Clear All Data (Ensuring Full Wipe)**
  static Future<void> clear() async {
    try {
      print("🔹 Clearing all local storage...");
      await _secureStorage.deleteAll();
      await _preferences?.clear();
      print("✅ All storage cleared successfully.");
    } catch (e) {
      print("❌ LocalStorage: Error clearing storage - $e");
    }
  }
}