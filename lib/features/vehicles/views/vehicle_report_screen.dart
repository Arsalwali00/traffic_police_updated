import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:GBPayUsers/core/local_storage.dart';

class VehicleReportScreen extends StatefulWidget {
  final Color? dynamicColor;

  const VehicleReportScreen({super.key, this.dynamicColor});

  @override
  _VehicleReportScreenState createState() => _VehicleReportScreenState();
}

class _VehicleReportScreenState extends State<VehicleReportScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vehicleRegController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _cnicImage;
  File? _vehicleImage;
  String _selectedIssueType = 'Traffic Violation';
  bool _isSubmitting = false;
  Color _dynamicColor = const Color(0xFF379E4B); // Default color

  final ImagePicker _picker = ImagePicker();

  final List<String> _issueTypes = [
    'Traffic Violation',
    'Wrong Parking',
    'Documents Issue',
    'Vehicle Condition',
    'Tax Related',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDynamicColor();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _vehicleRegController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchDynamicColor() async {
    // If color is passed from parent widget, use it
    if (widget.dynamicColor != null) {
      setState(() {
        _dynamicColor = widget.dynamicColor!;
      });
      return;
    }

    // Otherwise, fetch from local storage
    try {
      Map<String, dynamic>? userData = await LocalStorage.getUser();
      if (userData != null && mounted) {
        setState(() {
          try {
            if (userData['color'] != null) {
              String colorString = userData['color'].toString();
              if (colorString.startsWith('0x')) {
                colorString = colorString.replaceFirst('0x', '');
              }
              _dynamicColor = Color(int.parse(colorString, radix: 16) | 0xFF000000);
            }
          } catch (e) {
            print("Error parsing color: $e");
            _dynamicColor = const Color(0xFF379E4B); // Fallback to default
          }
        });
      }
    } catch (e) {
      print("Error fetching user data for color: $e");
      if (mounted) {
        setState(() {
          _dynamicColor = const Color(0xFF379E4B); // Fallback to default
        });
      }
    }
  }

  Color get _themeColor => _dynamicColor;

  // --------------------------------------------------------------
  // PICK IMAGE
  // --------------------------------------------------------------
  Future<void> _pickImage(String type) async {
    try {
      final XFile? pickedFile = await showModalBottomSheet<XFile?>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose Image Source',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.camera_alt, color: _themeColor, size: 30),
                    title: const Text('Camera', style: TextStyle(fontSize: 16)),
                    onTap: () async {
                      Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library, color: _themeColor, size: 30),
                    title: const Text('Gallery', style: TextStyle(fontSize: 16)),
                    onTap: () async {
                      Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (pickedFile != null) {
        setState(() {
          if (type == 'cnic') {
            _cnicImage = File(pickedFile.path);
          } else {
            _vehicleImage = File(pickedFile.path);
          }
        });
        _showSnackBar('Image captured successfully!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e', Colors.red);
    }
  }

  // --------------------------------------------------------------
  // REMOVE IMAGE
  // --------------------------------------------------------------
  void _removeImage(String type) {
    setState(() {
      if (type == 'cnic') {
        _cnicImage = null;
      } else {
        _vehicleImage = null;
      }
    });
  }

  // --------------------------------------------------------------
  // SUBMIT REPORT
  // --------------------------------------------------------------
  Future<void> _submitReport() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name', Colors.red);
      return;
    }
    if (_cnicController.text.trim().isEmpty) {
      _showSnackBar('Please enter CNIC number', Colors.red);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('Please enter phone number', Colors.red);
      return;
    }
    if (_vehicleRegController.text.trim().isEmpty) {
      _showSnackBar('Please enter vehicle registration number', Colors.red);
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showSnackBar('Please describe the issue', Colors.red);
      return;
    }
    if (_cnicImage == null) {
      _showSnackBar('Please capture CNIC photo', Colors.red);
      return;
    }
    if (_vehicleImage == null) {
      _showSnackBar('Please capture vehicle photo', Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    // Show success dialog
    _showSuccessDialog();
  }

  // --------------------------------------------------------------
  // SUCCESS DIALOG
  // --------------------------------------------------------------
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Report Submitted!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your vehicle report has been submitted successfully. Reference ID: VR-2024-12345',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Report Vehicle', style: TextStyle(color: Colors.black87)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INFO CARD
              Card(
                elevation: 0,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Report any vehicle-related issues with photos for verification',
                          style: TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // REPORTER DETAILS SECTION
              const Text(
                'Reporter Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // NAME
              _buildTextField(
                controller: _nameController,
                label: 'Full Name *',
                hint: 'Enter your full name',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // CNIC
              _buildTextField(
                controller: _cnicController,
                label: 'CNIC Number *',
                hint: 'XXXXX-XXXXXXX-X',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // PHONE
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number *',
                hint: '03XX-XXXXXXX',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              // VEHICLE DETAILS SECTION
              const Text(
                'Vehicle Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // VEHICLE REGISTRATION
              _buildTextField(
                controller: _vehicleRegController,
                label: 'Vehicle Registration Number *',
                hint: 'ABC-123 or ABC-1234',
                icon: Icons.directions_car,
              ),
              const SizedBox(height: 16),

              // ISSUE TYPE
              const Text(
                'Issue Type *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: _themeColor, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedIssueType,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    items: _issueTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedIssueType = newValue!);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // DESCRIPTION
              const Text(
                'Description *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _themeColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _themeColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _themeColor, width: 2.0),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // PHOTO SECTION
              const Text(
                'Required Photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // CNIC PHOTO
              _buildPhotoCard(
                title: 'CNIC Photo *',
                description: 'Take a clear photo of your CNIC',
                image: _cnicImage,
                onCapture: () => _pickImage('cnic'),
                onRemove: () => _removeImage('cnic'),
              ),

              const SizedBox(height: 16),

              // VEHICLE PHOTO
              _buildPhotoCard(
                title: 'Vehicle Photo *',
                description: 'Take a photo of the vehicle (including number plate)',
                image: _vehicleImage,
                onCapture: () => _pickImage('vehicle'),
                onRemove: () => _removeImage('vehicle'),
              ),

              const SizedBox(height: 32),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.send, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Report',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: Icon(icon, color: _themeColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _themeColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _themeColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _themeColor, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard({
    required String title,
    required String description,
    required File? image,
    required VoidCallback onCapture,
    required VoidCallback onRemove,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: _themeColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (image == null)
              InkWell(
                onTap: onCapture,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: _themeColor, width: 2, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                    color: _themeColor.withOpacity(0.05),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: _themeColor, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to capture photo',
                        style: TextStyle(color: _themeColor, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.refresh, color: _themeColor),
                            onPressed: onCapture,
                            tooltip: 'Retake',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: onRemove,
                            tooltip: 'Remove',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}