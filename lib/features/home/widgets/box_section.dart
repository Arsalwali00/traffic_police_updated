import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/features/home/widgets/dynamic_form_screen.dart';
import 'package:GBPayUsers/features/home/model/dynamic_form_model.dart';

class BoxSection extends StatefulWidget {
  final String title;
  final List<DepartmentForm> forms;
  final TextEditingController searchController;
  final VoidCallback? onSeeAllTap;

  const BoxSection({
    Key? key,
    required this.title,
    required this.forms,
    required this.searchController,
    this.onSeeAllTap,
  }) : super(key: key);

  @override
  _BoxSectionState createState() => _BoxSectionState();
}

class _BoxSectionState extends State<BoxSection> {
  List<FeeStructure> filteredFeeStructures = [];
  Color _dynamicColor = const Color(0xFF379E4B); // Default color

  @override
  void initState() {
    super.initState();
    filteredFeeStructures = widget.forms.expand((form) => form.feeStructures).toList();
    widget.searchController.addListener(_filterFeeStructures);
    _fetchDynamicColor();
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filterFeeStructures);
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

  void _filterFeeStructures() {
    final query = widget.searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredFeeStructures = widget.forms.expand((form) => form.feeStructures).toList();
      } else {
        filteredFeeStructures = widget.forms
            .expand((form) => form.feeStructures)
            .where((fee) => fee.title?.toLowerCase().contains(query) ?? false)
            .toList();
      }
    });
  }

  // Helper function to clean repetitive words like "the the"
  String cleanTitle(String? title) {
    if (title == null) return "Unknown Fee";
    // Remove duplicate consecutive words (e.g., "the the" -> "the")
    return title.replaceAll(RegExp(r'\b(\w+)\s+\1\b'), r'$1');
  }

  IconData _getIconForFee(String feeTitle) {
    final Map<String, IconData> feeIcons = {
      "Issuance": Icons.badge,
      "Renewal": Icons.refresh,
      "Fines": Icons.money_off,
      "Traffic": Icons.traffic,
      "License": Icons.card_membership,
      "Permit": Icons.security,
      "Registration": Icons.directions_car,
      "Certificate": Icons.verified_user,
      "Test": Icons.quiz,
      "Tour": Icons.travel_explore,
    };

    for (String key in feeIcons.keys) {
      if (feeTitle.toLowerCase().contains(key.toLowerCase())) {
        return feeIcons[key]!;
      }
    }
    return Icons.account_balance_wallet;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (widget.onSeeAllTap != null)
                TextButton(
                  onPressed: widget.onSeeAllTap,
                  child: Text(
                    "See all",
                    style: TextStyle(
                      color: _dynamicColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (filteredFeeStructures.isEmpty)
            const Center(child: Text("No fees found")),
          if (filteredFeeStructures.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredFeeStructures.length,
              itemBuilder: (context, index) {
                final fee = filteredFeeStructures[index];
                final parentForm = widget.forms.firstWhere(
                      (form) => form.feeStructures.contains(fee),
                );

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DynamicFormScreen(
                          formId: parentForm.formId,
                          feeStructureId: fee.feeStructureId,
                          formName: parentForm.formName,
                          amount: fee.amount,
                          formAttributes: parentForm.attributes,
                          feeTitle: fee.title ?? "Unknown Fee",
                          urduTitle: fee.urduTitle, // Pass urduTitle
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                    padding: EdgeInsets.all(screenWidth * 0.06),
                    constraints: BoxConstraints(
                      minHeight: screenHeight * 0.15, // Kept larger size for wrapped text
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _getIconForFee(fee.title ?? ""),
                          size: 48,
                          color: _dynamicColor,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cleanTitle(fee.title), // English title
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (fee.urduTitle != null) ...[
                                SizedBox(height: screenHeight * 0.005),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        fee.urduTitle!, // Urdu title
                                        style: const TextStyle(
                                          fontSize: 16, // Slightly larger font size
                                          fontWeight: FontWeight.bold, // Bold text
                                          color: Colors.black87,
                                          fontFamily: 'NotoNastaliqUrdu', // Suitable for Urdu text
                                        ),
                                        textDirection: TextDirection.rtl, // Right-to-left for Urdu
                                        textAlign: TextAlign.right, // Align text to right
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                "${fee.currency}${fee.amount.toInt()}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _dynamicColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}