import 'package:GBPayUsers/features/home/model/voucher_model.dart';
import 'package:GBPayUsers/core/voucher_service.dart';
import 'package:GBPayUsers/core/local_storage.dart';

class VoucherPresenter {
  /// 🔹 Fetch Voucher
  Future<VoucherResponse?> getVoucher(String psid) async {
    try {
      // ✅ Check for Auth Token
      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found. Please log in.");
        return null;
      }

      // ✅ Fetch Voucher from API
      VoucherResponse? response = await VoucherService.fetchVoucher(psid);

      if (response != null && response.status && response.data != null && response.data!.isNotEmpty) {
        print("✅ ${response.data!.length} voucher(s) retrieved successfully!");
        return response;
      } else {
        print("⚠️ No vouchers found for PSID: $psid.");
        return null;
      }
    } catch (e) {
      print("❌ Error in VoucherPresenter: $e");

      // 🔹 Check for Unauthorized Access (Token Expiry)
      if (e.toString().contains("401")) {
        print("⚠️ Token expired! Logging out user...");
        await LocalStorage.logout();
      }

      return null;
    }
  }

  /// 🔹 Fetch Generated Vouchers
  Future<List<VoucherData>?> getGeneratedVouchers() async {
    try {
      // ✅ Check for Auth Token
      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found. Please log in.");
        return null;
      }

      // ✅ Fetch Generated Vouchers from API
      List<VoucherData>? vouchers = await VoucherService.fetchGeneratedVouchers();

      if (vouchers != null && vouchers.isNotEmpty) {
        print("✅ Generated vouchers retrieved successfully!");
        return vouchers;
      } else {
        print("⚠️ No generated vouchers found.");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching generated vouchers in VoucherPresenter: $e");

      // 🔹 Check for Unauthorized Access (Token Expiry)
      if (e.toString().contains("401")) {
        print("⚠️ Token expired! Logging out user...");
        await LocalStorage.logout();
      }

      return null;
    }
  }

  /// 🔹 Fetch Vouchers by Date Range
  Future<List<VoucherData>?> getVouchersByDateRange({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      // ✅ Check for Auth Token
      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found. Please log in.");
        return null;
      }

      // ✅ Fetch Vouchers by Date Range from API
      List<VoucherData>? vouchers = await VoucherService.fetchVouchersByDateRange(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      if (vouchers != null && vouchers.isNotEmpty) {
        print("✅ Vouchers by date range retrieved successfully!");
        return vouchers;
      } else {
        print("⚠️ No vouchers found for date range: $dateFrom to $dateTo.");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching vouchers by date range in VoucherPresenter: $e");

      // 🔹 Check for Unauthorized Access (Token Expiry)
      if (e.toString().contains("401")) {
        print("⚠️ Token expired! Logging out user...");
        await LocalStorage.logout();
      }

      return null;
    }
  }

  /// 🔹 Request Voucher Deletion
  Future<bool> deleteVoucher({
    required String psid,
    required String remarks,
  }) async {
    try {
      // ✅ Check for Auth Token
      String? token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found. Please log in.");
        return false;
      }

      // ✅ Request Voucher Deletion from API
      bool success = await VoucherService.requestVoucherDeletion(
        psid: psid,
        remarks: remarks,
      );

      if (success) {
        print("✅ Voucher deletion requested successfully for PSID: $psid");
        return true;
      } else {
        print("⚠️ Failed to request voucher deletion.");
        return false;
      }
    } catch (e) {
      print("❌ Error requesting voucher deletion in VoucherPresenter: $e");

      // 🔹 Check for Unauthorized Access (Token Expiry)
      if (e.toString().contains("401")) {
        print("⚠️ Token expired! Logging out user...");
        await LocalStorage.logout();
      }

      return false;
    }
  }
}