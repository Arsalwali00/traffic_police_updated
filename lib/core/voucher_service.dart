import 'package:dio/dio.dart';
import 'package:GBPayUsers/config/api.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/features/home/model/voucher_model.dart';

class VoucherService {
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

  /// ✅ Fetch Voucher using `voucher_number` with Auth Token
  static Future<VoucherResponse?> fetchVoucher(String voucherNumber) async {
    try {
      print("📤 Requesting voucher for Voucher Number: $voucherNumber");

      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found.");
        return null;
      }

      Response response = await _dio.post(
        API.getVoucher,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          "voucher_number": voucherNumber,
        },
      );

      print("✅ Voucher retrieved: ${response.data}");
      return VoucherResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("❌ API Error: ${e.response?.statusCode} - ${e.message}");
      return null;
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return null;
    }
  }

  /// ✅ Fetch Generated Vouchers with Auth Token (Fixed to POST)
  static Future<List<VoucherData>?> fetchGeneratedVouchers() async {
    try {
      print("📤 Requesting generated vouchers via POST");

      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found.");
        return null;
      }

      Response response = await _dio.post(
        API.getGeneratedVouchers,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {}, // Empty body, auth token in header is sufficient
      );

      print("✅ Generated vouchers retrieved: ${response.data}");

      // Parse the response based on your API's structure
      final jsonData = response.data;
      if (jsonData is List) {
        return jsonData.map((json) => VoucherData.fromJson(json)).toList();
      } else if (jsonData['data'] is List) {
        return (jsonData['data'] as List).map((json) => VoucherData.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("❌ API Error: ${e.response?.statusCode} - ${e.response?.data}");
      return null;
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return null;
    }
  }

  /// ✅ Fetch Vouchers by Date Range with Auth Token, date_from, and date_to (POST)
  static Future<List<VoucherData>?> fetchVouchersByDateRange({
    required String dateFrom, // e.g., "2025-04-01"
    required String dateTo,   // e.g., "2025-04-09"
  }) async {
    try {
      print("📤 Requesting vouchers for date range: $dateFrom to $dateTo via POST");

      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found.");
        return null;
      }

      Response response = await _dio.post(
        API.getDateRangeVouchers,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          "date_from": dateFrom,
          "date_to": dateTo,
        },
      );

      print("✅ Vouchers by date range retrieved: ${response.data}");

      // Parse the response based on your API's structure
      final jsonData = response.data;
      if (jsonData is List) {
        return jsonData.map((json) => VoucherData.fromJson(json)).toList();
      } else if (jsonData['data'] is List) {
        return (jsonData['data'] as List).map((json) => VoucherData.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("❌ API Error: ${e.response?.statusCode} - ${e.response?.data}");
      return null;
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return null;
    }
  }

  /// ✅ Request Voucher Deletion with Auth Token, psid, and remarks (POST)
  static Future<bool> requestVoucherDeletion({
    required String psid,
    required String remarks,
  }) async {
    try {
      print("📤 Requesting voucher deletion for PSID: $psid with remarks: $remarks via POST");

      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found.");
        return false;
      }

      Response response = await _dio.post(
        API.voucherDeleteRequest,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          "psid": psid,
          "remarks": remarks,
        },
      );

      print("✅ Voucher deletion requested successfully: ${response.data}");
      return true;
    } on DioException catch (e) {
      print("❌ API Error: ${e.response?.statusCode} - ${e.response?.data}");
      return false;
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return false;
    }
  }
}