import 'package:flutter/material.dart';
import 'package:GBPayUsers/features/vehicles/model/vehicle_status_model.dart';
import 'package:intl/intl.dart';
import 'vehicle_report_screen.dart';

class VehicleDetailScreen extends StatelessWidget {
  final VehicleStatusModel vehicle;
  final Color dynamicColor;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
    required this.dynamicColor,
  });

  // Method to determine if vehicle is a tax defaulter
  bool _isTaxDefaulter(String taxPaidUpto) {
    if (taxPaidUpto.isEmpty) return true;

    try {
      // Parse the date from API
      final DateFormat dateFormat = DateFormat('dd-MMM-yy');
      DateTime taxPaidDate;

      try {
        taxPaidDate = dateFormat.parse(taxPaidUpto);
      } catch (e) {
        // Try uppercase format
        taxPaidDate = DateFormat('dd-MMM-yy').parseLoose(taxPaidUpto.toUpperCase());
      }

      final DateTime now = DateTime.now();

      // Calculate difference: taxPaidUpto - now
      final int daysDifference = taxPaidDate.difference(now).inDays;

      // Debug: Print to console
      print('=== DETAIL SCREEN TAX DEBUG ===');
      print('Original String: "$taxPaidUpto"');
      print('Parsed Date: $taxPaidDate');
      print('Today: $now');
      print('Days Difference: $daysDifference');
      print('Is Defaulter: ${daysDifference < -180}');
      print('================================');

      // Logic:
      // daysDifference >= 0: Tax valid (future/today) → NOT defaulter
      // daysDifference -1 to -180: Expired but within 6 months → NOT defaulter
      // daysDifference < -180: Expired over 6 months → IS defaulter
      return daysDifference < -180;
    } catch (e) {
      print('Error parsing date: $e');
      return true; // Invalid date = defaulter
    }
  }

  // Navigate to Report Screen
  void _navigateToReportScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VehicleReportScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDefaulter = _isTaxDefaulter(vehicle.taxPaidUpto);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: dynamicColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vehicle Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.report_problem, color: dynamicColor),
            tooltip: 'Report Vehicle',
            onPressed: () => _navigateToReportScreen(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Tax Status Badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDefaulter ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isDefaulter ? Colors.red : Colors.green).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDefaulter ? Icons.warning_rounded : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isDefaulter ? 'TAX DEFAULTER' : 'TAX PAID',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Vehicle Details Table
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Table(
                      border: TableBorder.symmetric(
                        inside: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      children: [
                        _buildTableRow('Registration Type', vehicle.registrationType, isFirst: true, index: 0),
                        _buildTableRow('Registration Number', vehicle.vehicleRegNo, index: 1),
                        _buildTableRow('Chassis Number', vehicle.chassisNo, index: 2),
                        _buildTableRow('Engine Number', vehicle.engineNo, index: 3),
                        _buildTableRow('Registration Date', vehicle.regDate, index: 4),
                        _buildTableRow('Make', vehicle.makeName, index: 5),
                        _buildTableRow('Engine Size', vehicle.engineSize, index: 6),
                        _buildTableRow('Status', vehicle.status, index: 7),
                        _buildTableRow('Category', vehicle.category, index: 8),
                        _buildTableRow('Body Type', vehicle.bodyType, index: 9),
                        _buildTableRow('Color', vehicle.color, index: 10),
                        _buildTableRow('Purchase Date', vehicle.purchaseDate, index: 11),
                        _buildTableRow('VPT Type', vehicle.vptType, index: 12),
                        _buildTableRow('Model Year', vehicle.modelYear.toString(), index: 13),
                        _buildTableRow('Tax Paid Upto', vehicle.taxPaidUpto, index: 14, isTaxField: true, isDefaulter: isDefaulter),
                        _buildTableRow('Owner Name', vehicle.ownerName, index: 15),
                        _buildTableRow('Owner Father Name', vehicle.ownerFatherName, index: 16),
                        _buildTableRow('CNIC', vehicle.cnic, index: 17),
                        _buildTableRow('NTN', vehicle.ntn, index: 18),
                        _buildTableRow('Contact Number', vehicle.contactNo, index: 19),
                        _buildTableRow('HPA', vehicle.hpa, index: 20),
                        _buildTableRow('Temporary Address', vehicle.tempAddress, index: 21),
                        _buildTableRow('Permanent Address', vehicle.permntAddress, isLast: true, index: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
      String label,
      String value, {
        bool isFirst = false,
        bool isLast = false,
        required int index,
        bool isTaxField = false,
        bool isDefaulter = false,
      }) {
    final isEven = index % 2 == 0;
    final backgroundColor = isEven ? Colors.grey[50] : Colors.white;

    // Determine text color for tax field
    Color valueColor;
    if (isTaxField) {
      valueColor = isDefaulter ? Colors.red : Colors.green;
    } else {
      valueColor = value.isEmpty ? Colors.grey[400]! : Colors.black87;
    }

    return TableRow(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: isFirst
              ? BorderSide(color: dynamicColor, width: 2)
              : BorderSide.none,
          bottom: isLast
              ? BorderSide(color: dynamicColor, width: 2)
              : BorderSide.none,
        ),
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Text(
            value.isEmpty ? 'N/A' : value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isTaxField ? FontWeight.w600 : FontWeight.w500,
              color: valueColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}