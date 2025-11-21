import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/vehicle_status_service.dart';
import 'package:GBPayUsers/features/vehicles/model/vehicle_status_model.dart';
import 'vehicle_detail_screen.dart';
import 'package:intl/intl.dart';
import 'vehicle_doc_scanner.dart';
import 'challan_type_selection_screen.dart'; // Import the new screen

class VehiclesScreen extends StatefulWidget {
  final Color dynamicColor;

  const VehiclesScreen({super.key, required this.dynamicColor});

  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _chassisNumberController = TextEditingController();
  final FocusNode _registrationFocusNode = FocusNode();
  final FocusNode _chassisFocusNode = FocusNode();
  bool _isLoading = false;
  bool _hasSearched = false;
  List<VehicleStatusModel> _vehicles = [];
  String? _errorMessage;

  final GBNumberPlateScanner _plateScanner = GBNumberPlateScanner();

  @override
  void initState() {
    super.initState();
    _registrationFocusNode.addListener(() => setState(() {}));
    _chassisFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _registrationNumberController.dispose();
    _chassisNumberController.dispose();
    _registrationFocusNode.dispose();
    _chassisFocusNode.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  // SCAN NUMBER PLATE
  // --------------------------------------------------------------
  Future<void> _scanPlate() async {
    try {
      final result = await _plateScanner.scanNumberPlate(context);
      if (result == null) return;

      setState(() {
        _registrationNumberController.text = result;
      });

      _showSnackBar('Scanned: $result', Colors.green);
    } catch (e) {
      _showSnackBar('Scan failed: $e', Colors.red);
    }
  }

  // --------------------------------------------------------------
  // FETCH VEHICLE STATUS
  // --------------------------------------------------------------
  Future<void> _fetchVehicleStatus() async {
    final reg = _registrationNumberController.text.trim();
    final chassis = _chassisNumberController.text.trim();

    if (reg.isEmpty && chassis.isEmpty) {
      _showSnackBar('Please enter a registration or chassis number.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _vehicles = [];
      _hasSearched = false;
    });

    final response = await VehicleStatusService.getVehicleStatus(
      registrationNumber: reg,
      chassisNumber: chassis,
      departmentCode: "23",
    );

    setState(() {
      _isLoading = false;
      _hasSearched = true;
    });

    if (response['success'] == true) {
      setState(() {
        _vehicles = (response['data'] as List<dynamic>)
            .map((item) => item as VehicleStatusModel)
            .toList();
      });
    } else {
      setState(() => _errorMessage = response['message']);
      _showSnackBar(_errorMessage ?? 'Failed to fetch vehicle status.', Colors.red);
    }
  }

  // --------------------------------------------------------------
  // CLEAR SEARCH
  // --------------------------------------------------------------
  void _clearSearch() {
    _registrationNumberController.clear();
    _chassisNumberController.clear();
    setState(() {
      _vehicles = [];
      _errorMessage = null;
      _hasSearched = false;
    });
  }

  // --------------------------------------------------------------
  // SHOW CHALLAN TYPE SELECTION SCREEN
  // --------------------------------------------------------------
  void _showChallanSelectionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallanTypeSelectionScreen(
          dynamicColor: widget.dynamicColor,
          registrationNumber: _registrationNumberController.text.trim(),
          chassisNumber: _chassisNumberController.text.trim(),
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // TAX COLOR (FOR BORDER ONLY)
  // --------------------------------------------------------------
  Color _getTaxPaidUptoColor(String taxPaidUpto) {
    if (taxPaidUpto.isEmpty) return Colors.red;
    try {
      final DateTime taxPaidDate = DateFormat('dd-MMM-yy').parseLoose(taxPaidUpto.toUpperCase());
      final int daysDiff = taxPaidDate.difference(DateTime.now()).inDays;
      return daysDiff >= -180 ? Colors.green : Colors.red;
    } catch (e) {
      return Colors.red;
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text('Vehicles',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Search registered vehicles here.',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      const SizedBox(height: 32),

                      // Registration Number
                      const Text('Registration Number:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _registrationNumberController,
                        focusNode: _registrationFocusNode,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter registration number (e.g., ABC-12-345)',
                          hintStyle: const TextStyle(color: Colors.black38),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: widget.dynamicColor, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: widget.dynamicColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: widget.dynamicColor, width: 2.0),
                          ),
                          suffixIcon: _registrationNumberController.text.isNotEmpty
                              ? Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: widget.dynamicColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white, size: 18),
                                onPressed: _clearSearch,
                              ),
                            ),
                          )
                              : null,
                        ),
                        onSubmitted: (_) => _fetchVehicleStatus(),
                      ),

                      const SizedBox(height: 16),

                      // Chassis Number
                      const Text('Chassis Number:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _chassisNumberController,
                        focusNode: _chassisFocusNode,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter chassis number',
                          hintStyle: const TextStyle(color: Colors.black38),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: widget.dynamicColor, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: widget.dynamicColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: widget.dynamicColor, width: 2.0),
                          ),
                          suffixIcon: _chassisNumberController.text.isNotEmpty
                              ? Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: widget.dynamicColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white, size: 18),
                                onPressed: _clearSearch,
                              ),
                            ),
                          )
                              : null,
                        ),
                        onSubmitted: (_) => _fetchVehicleStatus(),
                      ),

                      const SizedBox(height: 24),

                      // SCAN NUMBER PLATE BUTTON
                      if (!_hasSearched)
                        Center(
                          child: Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.qr_code_scanner, size: 48, color: widget.dynamicColor),
                                tooltip: 'Scan Number Plate',
                                onPressed: _scanPlate,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tap to scan number plate',
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                      if (!_hasSearched) const SizedBox(height: 16),

                      // SEARCH BUTTON
                      if (!_hasSearched)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _fetchVehicleStatus,
                            icon: const Icon(Icons.search, color: Colors.white),
                            label: const Text('Search', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.dynamicColor,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),

                      if (!_hasSearched) const SizedBox(height: 16),

                      // LOADING
                      if (_isLoading)
                        Center(child: CircularProgressIndicator(color: widget.dynamicColor)),

                      // RESULTS - SHOW VEHICLES
                      if (_vehicles.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = _vehicles[index];
                            final Color borderColor = vehicle.taxPaidUpto.isEmpty
                                ? Colors.red
                                : _getTaxPaidUptoColor(vehicle.taxPaidUpto);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VehicleDetailScreen(
                                      vehicle: vehicle,
                                      dynamicColor: widget.dynamicColor,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor, width: 1.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Vehicle: ${vehicle.vehicleRegNo}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Owner: ${vehicle.ownerName}', style: const TextStyle(color: Colors.black)),
                                        Text('Chassis No: ${vehicle.chassisNo}', style: const TextStyle(color: Colors.black)),
                                        Text('Engine No: ${vehicle.engineNo}', style: const TextStyle(color: Colors.black)),
                                        Text('Registration Date: ${vehicle.regDate}', style: const TextStyle(color: Colors.black)),
                                        Text('Model: ${vehicle.modelYear}', style: const TextStyle(color: Colors.black)),
                                        Text('Category: ${vehicle.category}', style: const TextStyle(color: Colors.black)),
                                        Text('District: ${vehicle.districtName}', style: const TextStyle(color: Colors.black)),
                                        Text(
                                          'Tax Paid Upto: ${vehicle.taxPaidUpto.isEmpty ? 'N/A' : vehicle.taxPaidUpto}',
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      // NO VEHICLE FOUND → SHOW GENERATE CHALLAN
                      if (!_isLoading && _vehicles.isEmpty && _hasSearched)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              const Text('No vehicle record found.',
                                  style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              const Text('Want to generate a challan against this vehicle?',
                                  style: TextStyle(color: Colors.black54, fontSize: 14), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _showChallanSelectionScreen,
                                icon: const Icon(Icons.receipt_long, color: Colors.white),
                                label: const Text('Generate Challan', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.dynamicColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // BEFORE SEARCH
                      if (!_isLoading && _vehicles.isEmpty && !_hasSearched)
                        const Center(
                          child: Text('No vehicle data found. Please search.',
                              style: TextStyle(color: Colors.black54)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}