import 'package:GBPayUsers/core/api_service.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/config/api.dart';

class FormService {
  /// ✅ **Submit Dynamic Form to API**
  static Future<Map<String, dynamic>> submitForm({
    required int formId,
    required int feeStructureId,
    required double amount,
    required Map<String, dynamic> formData,
  }) async {
    try {
      // 🔐 Get Auth Token
      String? authToken = await LocalStorage.getToken();
      if (authToken == null) {
        print("❌ FormService: No auth token found");
        return {'success': false, 'message': "User not authenticated. Please log in again."};
      }

      // 📦 Create Request Body
      Map<String, dynamic> requestBody = {
        "form_id": formId,
        "fee_structure_id": feeStructureId,
        "amount": amount,
        ...formData, // Spread formData with filtered attributes
      };
      print("📤 FormService: Request Body - $requestBody");

      // 📤 Send POST Request
      final response = await ApiService.post(API.submitForm, requestBody, withAuth: true);
      print("📥 FormService: Raw API Response - $response");

      // Handle possible nested response (e.g., {data: {status: true, ...}})
      dynamic status = response['status'];
      dynamic message = response['message'];
      dynamic data = response['data'];
      dynamic errors = response['errors'];

      if (response.containsKey('data') && response['data'] is Map) {
        status = response['data']['status'] ?? status;
        message = response['data']['message'] ?? message;
        data = response['data']['data'] ?? data;
        errors = response['data']['errors'] ?? errors;
      }

      // Align with backend's 'status' key
      if (status == true) {
        print("✅ FormService: Success - $message");
        final result = {
          'success': true,
          'message': message ?? "Form submitted successfully!",
          'data': data,
        };
        print("📤 FormService: Returning - $result");
        return result;
      } else {
        print("❌ FormService: Failure - $message");
        final result = {
          'success': false,
          'message': message ?? "Failed to submit form",
          'errors': errors,
        };
        print("📤 FormService: Returning - $result");
        return result;
      }
    } catch (e) {
      print("❌ FormService: Error Submitting Form - $e");
      final result = {'success': false, 'message': "A network error occurred. Try again."};
      print("📤 FormService: Returning - $result");
      return result;
    }
  }
}