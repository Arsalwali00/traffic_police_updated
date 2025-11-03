import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/vehicle_status_service.dart';
import 'package:GBPayUsers/features/vehicles/model/vehicle_status_model.dart';
import 'vehicle_detail_screen.dart';
import 'package:intl/intl.dart';

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
  List<VehicleStatusModel> _vehicles = [];
  String? _errorMessage;

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

  Future<void> _fetchVehicleStatus() async {
    if (_registrationNumberController.text.isEmpty && _chassisNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a registration or chassis number.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _vehicles = [];
    });

    final response = await VehicleStatusService.getVehicleStatus(
      registrationNumber: _registrationNumberController.text,
      chassisNumber: _chassisNumberController.text,
      departmentCode: "23",
    );

    setState(() {
      _isLoading = false;
    });

    if (response['success'] == true) {
      setState(() {
        _vehicles = (response['data'] as List<dynamic>)
            .map((item) => item as VehicleStatusModel)
            .toList();
      });
    } else {
      setState(() {
        _errorMessage = response['message'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Failed to fetch vehicle status.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getTaxPaidUptoColor(String taxPaidUpto) {
    try {
      // Parse the date from API - try multiple formats
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
      print('=== TAX COLOR DEBUG ===');
      print('Original String: "$taxPaidUpto"');
      print('Parsed Date: $taxPaidDate');
      print('Today: $now');
      print('Days Difference: $daysDifference');
      print('Result: ${daysDifference >= -180 ? "GREEN" : "RED"}');
      print('Check: $daysDifference >= -180 = ${daysDifference >= -180}');
      print('======================');

      // Logic:
      // daysDifference >= 0: Tax valid (future/today) → GREEN
      // daysDifference -1 to -180: Expired but within 6 months → GREEN
      // daysDifference < -180: Expired over 6 months → RED
      final Color result = daysDifference >= -180 ? Colors.green : Colors.red;
      return result;
    } catch (e) {
      print('Error parsing date: $e');
      return Colors.red;
    }
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
                        child: Text(
                          'Vehicles',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Search registered vehicles here.',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Registration Number:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextField(
                        controller: _registrationNumberController,
                        focusNode: _registrationFocusNode,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter registration number',
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
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: widget.dynamicColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white),
                                onPressed: () {
                                  _registrationNumberController.clear();
                                  setState(() {
                                    _vehicles = [];
                                    _errorMessage = null;
                                  });
                                  _registrationFocusNode.unfocus();
                                },
                              ),
                            ),
                          )
                              : null,
                        ),
                        onSubmitted: (value) {
                          _fetchVehicleStatus();
                          _registrationFocusNode.unfocus();
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chassis Number:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
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
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: widget.dynamicColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white),
                                onPressed: () {
                                  _chassisNumberController.clear();
                                  setState(() {
                                    _vehicles = [];
                                    _errorMessage = null;
                                  });
                                  _chassisFocusNode.unfocus();
                                },
                              ),
                            ),
                          )
                              : null,
                        ),
                        onSubmitted: (value) {
                          _fetchVehicleStatus();
                          _chassisFocusNode.unfocus();
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _fetchVehicleStatus,
                          icon: const Icon(Icons.search, color: Colors.white),
                          label: const Text('Search', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.dynamicColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        Center(
                          child: CircularProgressIndicator(color: widget.dynamicColor),
                        ),
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
                                          style: TextStyle(
                                            color: vehicle.taxPaidUpto.isEmpty
                                                ? Colors.red
                                                : _getTaxPaidUptoColor(vehicle.taxPaidUpto),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      if (!_isLoading && _vehicles.isEmpty && _errorMessage == null)
                        const Center(
                          child: Text(
                            'No vehicle data found. Please search.',
                            style: TextStyle(color: Colors.black54),
                          ),
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