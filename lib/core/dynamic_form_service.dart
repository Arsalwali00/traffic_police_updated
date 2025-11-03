import 'package:dio/dio.dart';
import '../config/api.dart';
import 'local_storage.dart';
import 'package:GBPayUsers/features/home/model/dynamic_form_model.dart'; // ✅ Import the proper model

class DynamicFormService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseApiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// ✅ **Fetch Dynamic Forms with Correct Model Parsing**
  static Future<DynamicFormResponse?> fetchDynamicForms({String departmentCode = "02"}) async {
    try {
      print("📤 Requesting forms for Department Code: $departmentCode");

      // Retrieve Auth Token
      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found.");
        return null;
      }

      Response response = await _dio.post(
        API.feeStructure, // ✅ API endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // ✅ Attach Token
          },
        ),
        data: {
          "department_code": departmentCode, // ✅ Send department code
        },
      );

      print("✅ Forms retrieved: ${response.data}");

      // Convert JSON to Model
      return DynamicFormResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("❌ API Error: ${e.response?.statusCode} - ${e.message}");
      return null;
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return null;
    }
  }
}
