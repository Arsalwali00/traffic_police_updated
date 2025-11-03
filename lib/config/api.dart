class ApiConfig {
  // Centralized base URL - change this when needed
  static const String _baseUrl = "https://gbpay.gov.pk";
  static const String apiVersion = "/api/v1";
  static const String assetBaseUrl = "$_baseUrl/assets"; // For assets like department_logo

  // Full API base URL
  static const String baseApiUrl = "$_baseUrl$apiVersion";
}

class API {
  // 🔹 Authentication Endpoints
  static const String login = "${ApiConfig.baseApiUrl}/user-login";
  static const String logout = "${ApiConfig.baseApiUrl}/logout";

  // 🔹 Dynamic Forms
  static const String feeStructure = "${ApiConfig.baseApiUrl}/field-user/fee-structures";
  static const String submitForm = "${ApiConfig.baseApiUrl}/dynamic-forms/store";

  // 🔹 Voucher API
  static const String getVoucher = "${ApiConfig.baseApiUrl}/get-voucher";
  static const String getGeneratedVouchers = "${ApiConfig.baseApiUrl}/get-generated-vouchers";
  static const String getDateRangeVouchers = "${ApiConfig.baseApiUrl}/get-date-range-wise-vouchers";
  static const String voucherDeleteRequest = "${ApiConfig.baseApiUrl}/voucher-delete-request";

  // 🔹 Statistics API
  static const String userStatistic = "${ApiConfig.baseApiUrl}/user-statistic";

  // 🔹 Vehicle Status API
  static const String getVehicleStatus = "${ApiConfig.baseApiUrl}/excise/get-vehicle-status";
}