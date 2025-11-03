import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/api.dart';
import 'local_storage.dart';

class ApiService {
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

  /// ✅ Attach Authorization Token
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    String? token = await LocalStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (withAuth && token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// ✅ POST Request with Enhanced Error Handling and Retry Logic
  static Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data, {
        bool withAuth = true,
        int retries = 3,
      }) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        print("📤 Attempt ${attempt + 1} - Sending POST Request to: $endpoint");
        print("📦 Request Data: ${jsonEncode(data)}");

        Response response = await _dio.post(
          endpoint,
          data: jsonEncode(data),
          options: Options(headers: await _getHeaders(withAuth: withAuth)),
        );

        print("✅ Success! Response: ${response.data}");
        return {'success': true, 'data': response.data};
      } on DioException catch (e) {
        attempt++;
        if (attempt == retries) {
          if (e.response != null) {
            print("❌ API Error [${e.response?.statusCode}]: ${e.response?.data}");
            return {
              'success': false,
              'message': e.response?.data['message'] ?? "Something went wrong",
              'status': e.response?.statusCode,
            };
          } else if (e.type == DioExceptionType.connectionTimeout) {
            print("❌ Connection Timeout Error: ${e.message}");
            return {'success': false, 'message': "Connection timeout. Please try again."};
          } else if (e.type == DioExceptionType.receiveTimeout) {
            print("❌ Receive Timeout Error: ${e.message}");
            return {'success': false, 'message': "Server took too long to respond."};
          } else if (e.type == DioExceptionType.badCertificate || e.type == DioExceptionType.badResponse) {
            print("❌ SSL or Bad Response Error: ${e.message}");
            return {'success': false, 'message': "Security error: Invalid SSL certificate or bad response."};
          } else {
            print("❌ Network Error: ${e.message}");
            return {'success': false, 'message': "Network issue: Please check your internet connection."};
          }
        }
        // Wait briefly before retrying
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        print("❌ Unexpected Error: $e");
        return {'success': false, 'message': "An unexpected error occurred."};
      }
    }
    return {'success': false, 'message': "Failed after $retries attempts."};
  }
}