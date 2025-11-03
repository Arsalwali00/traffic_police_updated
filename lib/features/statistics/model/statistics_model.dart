// statistics_model.dart
import 'dart:convert';

class StatisticsModel {
  final double totalVouchers;
  final double paidAmount;
  final double unpaidAmount;
  final double todaysCollection;

  StatisticsModel({
    required this.totalVouchers,
    required this.paidAmount,
    required this.unpaidAmount,
    required this.todaysCollection,
  });

  /// Factory constructor with full null safety and type handling
  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalVouchers: _parsePKRAmount(json['total_vouchers'], 0.0),
      paidAmount: _parsePKRAmount(json['paid_amount'], 0.0),
      unpaidAmount: _parsePKRAmount(json['unpaid_amount'], 0.0),
      todaysCollection: _parsePKRAmount(json['todays_collection'], 0.0),
    );
  }

  /// Convert model to JSON safely
  Map<String, dynamic> toJson() {
    return {
      'total_vouchers': 'PKR. $totalVouchers',
      'paid_amount': 'PKR. $paidAmount',
      'unpaid_amount': 'PKR. $unpaidAmount',
      'todays_collection': 'PKR. $todaysCollection',
    };
  }

  /// Helper method to parse PKR amount strings
  static double _parsePKRAmount(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Handle multiple PKR formats (e.g., "PKR. 9500", "PKR 9500", "9500")
      String cleanValue = value.replaceAll(RegExp(r'PKR[\.\s]*'), '').trim();
      return double.tryParse(cleanValue) ?? fallback;
    }
    return fallback;
  }
}