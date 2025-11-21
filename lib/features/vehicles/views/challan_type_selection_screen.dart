import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/dynamic_form_service.dart';
import 'package:GBPayUsers/features/home/widgets/dynamic_form_screen.dart';

class ChallanTypeSelectionScreen extends StatefulWidget {
  final Color dynamicColor;
  final String registrationNumber;
  final String chassisNumber;

  const ChallanTypeSelectionScreen({
    super.key,
    required this.dynamicColor,
    required this.registrationNumber,
    required this.chassisNumber,
  });

  @override
  _ChallanTypeSelectionScreenState createState() => _ChallanTypeSelectionScreenState();
}

class _ChallanTypeSelectionScreenState extends State<ChallanTypeSelectionScreen> {
  bool _isLoading = false;

  // Fee titles for the two options - FIXED to match JSON data
  static const String _motorcycleFeeTitle = "C02638 Without Registration Motorcycle";
  static const String _otherVehicleFeeTitle = "C02638 Without Registration Other Than 2 Wheeler";
  static const int _targetFormId = 10;

  // --------------------------------------------------------------
  // GENERATE CHALLAN WITH SELECTED TYPE
  // --------------------------------------------------------------
  Future<void> _generateChallanWithType(String feeTitle) async {
    setState(() => _isLoading = true);

    try {
      final response = await DynamicFormService.fetchDynamicForms();

      if (response == null || !response.status || response.forms.isEmpty) {
        _showSnackBar("Form not available. Try again.", Colors.red);
        return;
      }

      // Step 1: Find Form ID 10
      final challanForm = response.forms.firstWhere(
            (f) => f.formId == _targetFormId,
        orElse: () => throw Exception("Form ID $_targetFormId not found"),
      );

      // Step 2: Find Exact Fee Title
      final fee = challanForm.feeStructures.firstWhere(
            (f) => f.title == feeTitle,
        orElse: () => throw Exception("Fee '$feeTitle' not found"),
      );

      // Step 3: Pre-fill registration & chassis
      final Map<String, String> prefillData = {};
      for (var attr in challanForm.attributes) {
        final name = attr.attributeName.toLowerCase();
        if (name.contains('registration') && widget.registrationNumber.isNotEmpty) {
          prefillData[attr.attributeName] = widget.registrationNumber;
        } else if (name.contains('chassis') && widget.chassisNumber.isNotEmpty) {
          prefillData[attr.attributeName] = widget.chassisNumber;
        }
      }

      // Step 4: Navigate to Dynamic Form
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DynamicFormScreen(
              formId: challanForm.formId,
              feeStructureId: fee.feeStructureId,
              formName: challanForm.formName,
              amount: fee.amount,
              formAttributes: challanForm.attributes,
              feeTitle: fee.title ?? "Vehicle Challan",
              urduTitle: fee.urduTitle,
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackBar("Challan form not found. Please try again.", Colors.red);
      debugPrint("Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --------------------------------------------------------------
  // SNACKBAR
  // --------------------------------------------------------------
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Vehicle Type for Challan',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: widget.dynamicColor),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Large Icon in Center
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.dynamicColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: widget.dynamicColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Option 1: Motorcycle
              _buildChallanOption(
                icon: Icons.motorcycle,
                title: 'Without Registration\nMotorcycle',
                onTap: () => _generateChallanWithType(_motorcycleFeeTitle),
              ),

              const SizedBox(height: 16),

              // Option 2: Other Than 2 Wheeler
              _buildChallanOption(
                icon: Icons.directions_car,
                title: 'Without Registration\nOther Than 2 Wheeler',
                onTap: () => _generateChallanWithType(_otherVehicleFeeTitle),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallanOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.dynamicColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 40, color: widget.dynamicColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}