// statistics_presenter.dart
import 'package:GBPayUsers/core/api_service.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/features/statistics/model/statistics_model.dart';
import 'package:GBPayUsers/config/api.dart';

class StatisticsPresenter {
  /// 🔹 Fetch Statistics Data
  Future<StatisticsModel?> getStatistics() async {
    try {
      // ✅ Check for Auth Token
      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found. Please log in.");
        return null;
      }

      // ✅ Fetch Statistics from API
      final response = await ApiService.post(
        "${ApiConfig.baseApiUrl}/user-statistic",
        {}, // Empty body for POST request
        withAuth: true,
      );
      print("Raw API response: $response");
      print("Success type: ${response['success'].runtimeType}, value: ${response['success']}");
      print("Data status type: ${response['data']?['status']?.runtimeType}, value: ${response['data']?['status']}");

      // Check top-level success and nested data status
      if (response['success'] == true || response['success'] == "true") {
        if (response['data'] != null && (response['data']['status'] == true || response['data']['status'] == "true")) {
          print("✅ Statistics retrieved successfully!");
          final stats = StatisticsModel.fromJson(response['data']);
          print("Parsed StatisticsModel: $stats");
          return stats;
        } else {
          print("⚠️ No statistics data found in data field: ${response['data']?['message'] ?? 'Unknown error'}");
          return null;
        }
      } else {
        print("⚠️ API call failed: ${response['message'] ?? 'Unknown error'}");
        return null;
      }
    } catch (e) {
      print("❌ Error in StatisticsPresenter: $e");
      // 🔹 Check for Unauthorized Access (Token Expiry)
      if (e.toString().contains("401")) {
        print("⚠️ Token expired! Logging out user...");
        await LocalStorage.logout();
      }
      return null;
    }
  }
}