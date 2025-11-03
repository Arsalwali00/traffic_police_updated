class VehicleStatusModel {
  final String vehicleRegNo;
  final String chassisNo;
  final String engineNo;
  final String regDate;
  final String makeName;
  final String engineSize;
  final String status;
  final String category;
  final String bodyType;
  final String color;
  final String purchaseDate;
  final String vptType;
  final int modelYear;
  final String taxPaidUpto;
  final String ownerName;
  final String ownerFatherName;
  final String cnic;
  final String districtName;
  final String registrationType;
  final String ntn;
  final String contactNo;
  final String hpa;
  final String tempAddress;
  final String permntAddress;

  VehicleStatusModel({
    required this.vehicleRegNo,
    required this.chassisNo,
    required this.engineNo,
    required this.regDate,
    required this.makeName,
    required this.engineSize,
    required this.status,
    required this.category,
    required this.bodyType,
    required this.color,
    required this.purchaseDate,
    required this.vptType,
    required this.modelYear,
    required this.taxPaidUpto,
    required this.ownerName,
    required this.ownerFatherName,
    required this.cnic,
    required this.districtName,
    required this.registrationType,
    required this.ntn,
    required this.contactNo,
    required this.hpa,
    required this.tempAddress,
    required this.permntAddress,
  });

  factory VehicleStatusModel.fromJson(Map<String, dynamic> json) {
    return VehicleStatusModel(
      vehicleRegNo: _parseString(json['VEH_REG_NO'], ''),
      chassisNo: _parseString(json['VEH_CHASIS_NO'], ''),
      engineNo: _parseString(json['VEH_ENGINE_NO'], ''),
      regDate: _parseString(json['VEH_REG_DATE'], ''),
      makeName: _parseString(json['MAK_NAME'], ''),
      engineSize: _parseString(json['VEH_ENGINE_SIZE'], ''),
      status: _parseString(json['VHS_NAME'], ''),
      category: _parseString(json['CAT_NAME'], ''),
      bodyType: _parseString(json['BODYTYPE'], ''),
      color: _parseString(json['COLOR'], ''),
      purchaseDate: _parseString(json['PURCHASE_DATE'], ''),
      vptType: _parseString(json['VPT_TYPE'], ''),
      modelYear: _parseInt(json['VEH_YEAR_OF_MANF'] ?? json['VEH_MODEL'], 0),
      taxPaidUpto: _parseString(json['VEH_TAX_PAID_UPTO/lIFE TIME'], ''),
      ownerName: _parseString(json['OWN_NAME'], ''),
      ownerFatherName: _parseString(json['OWN_F_H_NAME'], ''),
      cnic: _parseString(json['CNIC'], ''),
      districtName: _parseString(json['DIS_NAME'], ''),
      registrationType: _parseString(json['REGISTRATION_TYPE'], ''),
      ntn: _parseString(json['NTN'], ''),
      contactNo: _parseString(json['CONTACT_NO'], ''),
      hpa: _parseString(json['HPA'], ''),
      tempAddress: _parseString(json['TEMP_ADDRESS'], ''),
      permntAddress: _parseString(json['PERMNT_ADDRESS'], ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'VEH_REG_NO': vehicleRegNo,
      'VEH_CHASIS_NO': chassisNo,
      'VEH_ENGINE_NO': engineNo,
      'VEH_REG_DATE': regDate,
      'MAK_NAME': makeName,
      'VEH_ENGINE_SIZE': engineSize,
      'VHS_NAME': status,
      'CAT_NAME': category,
      'BODYTYPE': bodyType,
      'COLOR': color,
      'PURCHASE_DATE': purchaseDate,
      'VPT_TYPE': vptType,
      'VEH_YEAR_OF_MANF': modelYear,
      'VEH_TAX_PAID_UPTO/lIFE TIME': taxPaidUpto,
      'OWN_NAME': ownerName,
      'OWN_F_H_NAME': ownerFatherName,
      'CNIC': cnic,
      'DIS_NAME': districtName,
      'REGISTRATION_TYPE': registrationType,
      'NTN': ntn,
      'CONTACT_NO': contactNo,
      'HPA': hpa,
      'TEMP_ADDRESS': tempAddress,
      'PERMNT_ADDRESS': permntAddress,
    };
  }

  static String _parseString(dynamic value, String fallback) {
    return value?.toString() ?? fallback;
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    if (value is num) return value.toInt();
    return fallback;
  }
}