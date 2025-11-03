/// Helper to parse int from dynamic (handles String, num, null)
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt();
  return null;
}

/// Helper to parse double from dynamic (handles String, num, null)
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Helper to parse bool from dynamic (handles String, num, bool, null)
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) {
    String lowerValue = value.toLowerCase();
    return lowerValue == 'true' || lowerValue == '1';
  }
  return null;
}

class VoucherResponse {
  final bool status;
  final List<VoucherData>? data;
  final String message;

  VoucherResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  /// ✅ Convert JSON to `VoucherResponse` with robust type handling
  factory VoucherResponse.fromJson(Map<String, dynamic> json) {
    return VoucherResponse(
      status: _parseBool(json['status']) ?? false,
      data: json['data'] is List
          ? (json['data'] as List)
          .map((item) => VoucherData.fromJson(item as Map<String, dynamic>))
          .toList()
          : null,
      message: json['message']?.toString() ?? "No message",
    );
  }

  /// ✅ Convert `VoucherResponse` to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.map((voucher) => voucher.toJson()).toList(),
      'message': message,
    };
  }
}

class VoucherData {
  final String psid;
  final String departmentName;
  final String citizenName;
  final String dateTime;
  final String billMonth;
  final int billYear;
  final String headOfAccount;
  final String description;
  final double amount;
  final String amountInWords;
  final String qrCodeLink;
  final int paidAmount;
  final String? paymentDate;
  final String paymentTime;
  final bool isPaid;
  final String districtName;
  final String? vehicleNumber;

  VoucherData({
    required this.psid,
    required this.departmentName,
    required this.citizenName,
    required this.dateTime,
    required this.billMonth,
    required this.billYear,
    required this.headOfAccount, // Fixed parameter name
    required this.description,
    required this.amount,
    required this.amountInWords,
    required this.qrCodeLink,
    required this.paidAmount,
    this.paymentDate,
    required this.paymentTime,
    required this.isPaid,
    required this.districtName,
    this.vehicleNumber,
  });

  /// ✅ Convert JSON to `VoucherData` with robust type handling
  factory VoucherData.fromJson(Map<String, dynamic> json) {
    return VoucherData(
      psid: json['PSID']?.toString() ?? "",
      departmentName: json['department_name']?.toString() ?? "Unknown Department",
      citizenName: json['citizen_name']?.toString() ?? "No Name Provided",
      dateTime: json['date_time']?.toString() ?? "",
      billMonth: json['bill_month']?.toString() ?? "",
      billYear: _parseInt(json['bill_year']) ?? 0,
      headOfAccount: json['head_of_account']?.toString() ?? "",
      description: json['Description']?.toString() ?? "",
      amount: _parseDouble(json['amount']) ?? 0.0,
      amountInWords: json['amount_in_words']?.toString() ?? "",
      qrCodeLink: json['QR_code_link']?.toString() ?? "",
      paidAmount: _parseInt(json['paid_amount']) ?? 0,
      paymentDate: json['payment_date']?.toString(),
      paymentTime: json['payment_time']?.toString() ?? "",
      isPaid: _parseBool(json['is_paid']) ?? false,
      districtName: json['district_name']?.toString() ?? "N/A",
      vehicleNumber: json['vehicle_number']?.toString(),
    );
  }

  /// ✅ Convert `VoucherData` to JSON
  Map<String, dynamic> toJson() {
    return {
      'PSID': psid,
      'department_name': departmentName,
      'citizen_name': citizenName,
      'date_time': dateTime,
      'bill_month': billMonth,
      'bill_year': billYear,
      'head_of_account': headOfAccount, // Fixed key name
      'Description': description,
      'amount': amount,
      'amount_in_words': amountInWords,
      'QR_code_link': qrCodeLink,
      'paid_amount': paidAmount,
      'payment_date': paymentDate,
      'payment_time': paymentTime,
      'is_paid': isPaid ? 1 : 0,
      'district_name': districtName,
      'vehicle_number': vehicleNumber,
    };
  }
}