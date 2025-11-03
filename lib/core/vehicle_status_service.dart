import 'dart:convert';
import 'package:GBPayUsers/core/api_service.dart';
import 'package:GBPayUsers/config/api.dart';
import 'package:GBPayUsers/features/vehicles/model/vehicle_status_model.dart';
import 'local_storage.dart';

class VehicleStatusService {
  static Future<Map<String, dynamic>> getVehicleStatus({
    String? registrationNumber,
    String? chassisNumber,
    String departmentCode = "23",
  }) async {
    try {
      final token = await LocalStorage.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'User not authenticated. Please log in again.',
        };
      }

      final reg = registrationNumber?.trim();
      final ch = chassisNumber?.trim();

      // Validate: exactly one field
      if ((reg == null || reg.isEmpty) && (ch == null || ch.isEmpty)) {
        return {
          'success': false,
          'message': 'Please enter registration number or chassis number.',
        };
      }

      if ((reg != null && reg.isNotEmpty) && (ch != null && ch.isNotEmpty)) {
        return {
          'success': false,
          'message': 'Please search using only one field at a time.',
        };
      }

      final Map<String, dynamic> body = {
        "department_code": departmentCode,
      };

      if (reg != null && reg.isNotEmpty) {
        body["registration_number"] = reg;
        body["chassis_number"] = "SEARCH_BY_REG";
      } else if (ch != null && ch.isNotEmpty) {
        body["chassis_number"] = ch;
        body["registration_number"] = "SEARCH_BY_CHASSIS";
      }

      print("VehicleStatusService → Request Body: ${jsonEncode(body)}");

      final raw = await ApiService.post(
        API.getVehicleStatus,
        body,
        withAuth: true,
      );

      print("VehicleStatusService → Raw API Response: $raw");

      // FIXED: Check for 'success' instead of 'status'
      final bool success = raw['success'] == true || raw['success'] == 'true';

      if (!success) {
        return {
          'success': false,
          'message': raw['message']?.toString() ?? 'Failed to fetch vehicle data.',
          'errors': raw['errors'],
        };
      }

      // The actual API response is nested inside raw['data']
      final dynamic apiResponse = raw['data'];

      if (apiResponse == null) {
        return {
          'success': false,
          'message': 'No data received from server.',
        };
      }

      // Check the nested status
      final bool apiStatus = apiResponse['status'] == true || apiResponse['status'] == 'true';

      if (!apiStatus) {
        return {
          'success': false,
          'message': apiResponse['message']?.toString() ?? 'Failed to fetch vehicle data.',
        };
      }

      // Extract the vehicle data array
      final dynamic vehicleData = apiResponse['data'];

      if (vehicleData is List) {
        if (vehicleData.isEmpty) {
          return {
            'success': false,
            'message': 'No vehicle found with the provided details.',
            'data': <VehicleStatusModel>[],
          };
        }

        final List<VehicleStatusModel> vehicles = vehicleData
            .map((e) => VehicleStatusModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'message': 'Vehicle data retrieved successfully.',
          'data': vehicles,
        };
      }

      // No valid data
      return {
        'success': false,
        'message': 'Invalid data format received from server.',
        'data': <VehicleStatusModel>[],
      };
    } catch (e, s) {
      print("VehicleStatusService → Exception: $e\n$s");
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }
}