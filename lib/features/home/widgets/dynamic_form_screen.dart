import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/features/home/model/dynamic_form_model.dart';
import 'package:GBPayUsers/features/home/widgets/challan_receipt_screen.dart';
import '../../../core/form_service.dart';
import '../model/challan_receipt_model.dart';
import 'cnic_scanner.dart';

class DynamicFormScreen extends StatefulWidget {
  final int formId;
  final int feeStructureId;
  final String formName;
  final double amount;
  final List<FormFieldAttribute> formAttributes;
  final String feeTitle;
  final String? urduTitle;

  const DynamicFormScreen({
    Key? key,
    required this.formId,
    required this.feeStructureId,
    required this.formName,
    required this.amount,
    required this.formAttributes,
    required this.feeTitle,
    this.urduTitle,
  }) : super(key: key);

  @override
  _DynamicFormScreenState createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;
  Color _dynamicColor = const Color(0xFF379E4B);

  @override
  void initState() {
    super.initState();
    for (var attribute in widget.formAttributes) {
      _controllers[attribute.attributeName] = TextEditingController(
        text: _formData[attribute.attributeName] ?? attribute.defaultValues,
      );
    }
    _fetchDynamicColor();
    debugPrint("✅ [DEBUG] Form ID: ${widget.formId}");
    debugPrint("✅ [DEBUG] Amount: ${widget.amount}");
    debugPrint("✅ [DEBUG] Fee Title: ${widget.feeTitle}");
    debugPrint("✅ [DEBUG] Urdu Title: ${widget.urduTitle}");
    debugPrint("✅ [DEBUG] Received Attributes: ${widget.formAttributes.map((e) => e.attributeName).toList()}");
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchDynamicColor() async {
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
            debugPrint("Error parsing color: $e");
            _dynamicColor = const Color(0xFF379E4B);
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data for color: $e");
      if (mounted) {
        setState(() {
          _dynamicColor = const Color(0xFF379E4B);
        });
      }
    }
  }

  Future<void> _scanAndFillForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scanner = CnicScanner();
      final scannedData = await scanner.scanCnic(context);

      if (scannedData != null && mounted) {
        debugPrint("Scanned Data: $scannedData");
        setState(() {
          for (var attribute in widget.formAttributes) {
            if (attribute.attributeName.toLowerCase() == 'name' && scannedData.containsKey('name')) {
              _formData['name'] = scannedData['name'];
              _controllers['name']?.text = scannedData['name'];
            } else if (attribute.attributeName.toLowerCase() == 'cnic_number' && scannedData.containsKey('cnic_number')) {
              _formData['cnic_number'] = scannedData['cnic_number'];
              _controllers['cnic_number']?.text = scannedData['cnic_number'];
            }
          }
          debugPrint("Updated _formData: $_formData");
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Form fields filled from Identity Card scan!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Color(0xFF379E4B),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No data scanned from Identity Card",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error during Identity Card scanning: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to scan Identity Card: $e",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.feeTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.03,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.urduTitle != null) ...[
                          Text(
                            widget.urduTitle!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'NotoNastaliqUrdu',
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                        ],
                        Text(
                          "Fill the Form",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "Amount: ${widget.amount.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _dynamicColor,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        ...widget.formAttributes.map((attribute) => _buildFormField(attribute)).toList(),
                        SizedBox(height: screenHeight * 0.03),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.qr_code_scanner,
                                color: _dynamicColor,
                                size: 40,
                              ),
                              tooltip: 'Tap to Scan',
                              onPressed: _isLoading ? null : _scanAndFillForm,
                            ),
                            Text(
                              'Tap to Scan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _dynamicColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        SizedBox(
                          width: screenWidth * 0.8,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _submitForm();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _dynamicColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormField(FormFieldAttribute attribute) {
    switch (attribute.inputType.toLowerCase()) {
      case "text":
        return _buildLabeledField(attribute.label, attribute.urduLabel, _buildTextField(attribute));
      case "number":
        return _buildLabeledField(attribute.label, attribute.urduLabel, _buildNumberField(attribute));
      case "select":
        return _buildLabeledField(attribute.label, attribute.urduLabel, _buildDropdownField(attribute));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextField(FormFieldAttribute attribute) {
    return _buildInputField(
      attribute,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildNumberField(FormFieldAttribute attribute) {
    return _buildInputField(
      attribute,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDropdownField(FormFieldAttribute attribute) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        value: _formData[attribute.attributeName] ?? attribute.defaultValues,
        items: attribute.attributeList
            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black))))
            .toList(),
        onChanged: (value) => setState(() {
          _formData[attribute.attributeName] = value;
          _controllers[attribute.attributeName]?.text = value ?? '';
        }),
        decoration: _inputDecoration(),
        style: const TextStyle(color: Colors.black),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: _dynamicColor),
      ),
    );
  }

  Widget _buildInputField(FormFieldAttribute attribute, {TextInputType? keyboardType}) {
    final isName = attribute.attributeName.toLowerCase() == 'name';

    debugPrint("Field ${attribute.attributeName} controller text: ${_controllers[attribute.attributeName]?.text}");

    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: _controllers[attribute.attributeName],
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        cursorColor: _dynamicColor,
        maxLength: attribute.maxLength != null ? int.tryParse(attribute.maxLength!) : null,
        decoration: _inputDecoration(),
        validator: (value) {
          if (isName && (value == null || value.isEmpty)) {
            return 'Please enter a valid name';
          }
          return null;
        },
        onSaved: (value) {
          _formData[attribute.attributeName] = value;
        },
        onChanged: (value) {
          _formData[attribute.attributeName] = value;
          _controllers[attribute.attributeName]?.text = value;
        },
      ),
    );
  }

  Widget _buildLabeledField(String label, String? urduLabel, Widget field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.ltr,
                ),
                if (urduLabel != null)
                  Text(
                    urduLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'NotoNastaliqUrdu',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
              ]
          ),
          const SizedBox(height: 8),
          field,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _dynamicColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    debugPrint("✅ Form Submitted:");
    debugPrint("Form ID: ${widget.formId}");
    debugPrint("Fee Structure ID: ${widget.feeStructureId}");
    debugPrint("Amount: ${widget.amount}");
    debugPrint("Raw Form Data: $_formData");

    Map<String, dynamic> filteredFormData = {};
    for (var attribute in widget.formAttributes) {
      if (_formData.containsKey(attribute.attributeName)) {
        filteredFormData[attribute.attributeName] = _formData[attribute.attributeName];
      }
    }
    debugPrint("Filtered Form Data: $filteredFormData");

    final result = await FormService.submitForm(
      formId: widget.formId,
      feeStructureId: widget.feeStructureId,
      amount: widget.amount,
      formData: filteredFormData,
    );

    setState(() {
      _isLoading = false;
    });

    debugPrint("📥 DynamicFormScreen: FormService Result - $result");

    if (result['success'] == true) {
      try {
        debugPrint("Received JSON data: ${result['data']}");
        final receipt = ChallanReceiptModel.fromJson(result['data'] as Map<String, dynamic>);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? "Challan Generated Successfully!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: _dynamicColor,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallanReceiptScreen(receipt: receipt),
          ),
        );
      } catch (e) {
        debugPrint("Error parsing receipt: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error processing receipt: $e",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      String errorMessage = result['message'] ?? "Failed to Generate Challan";
      if (result['errors'] != null) {
        Map<String, dynamic> errors = result['errors'];
        errorMessage = errors.entries.map((e) => "${e.key}: ${e.value.join(', ')}").join('\n');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}