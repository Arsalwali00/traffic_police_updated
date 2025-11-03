import 'package:GBPayUsers/features/home/model/dynamic_form_model.dart';
import 'package:GBPayUsers/core/dynamic_form_service.dart';
import 'package:GBPayUsers/core/local_storage.dart';

class DynamicFormPresenter {
  /// 🔹 **Fetch Dynamic Forms**
  Future<DynamicFormResponse?> getDynamicForms() async {
    try {
      // ✅ Fetch Forms from API
      DynamicFormResponse? response = await DynamicFormService.fetchDynamicForms();

      if (response != null && response.status) {
        print("✅ Dynamic forms retrieved successfully!");
        return response;
      } else {
        print("⚠️ No forms found.");
        return null;
      }
    } catch (e) {
      print("❌ Error in DynamicFormPresenter: $e");

      // 🔹 **Check for Unauthorized Access (Token Expiry)**
      if (e.toString().contains("401")) {
        print("⚠️ Token expired! Logging out user...");
        await LocalStorage.logout();
      }

      return null;
    }
  }
}
