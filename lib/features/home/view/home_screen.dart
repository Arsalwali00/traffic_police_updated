import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/features/home/widgets/home_top_section.dart';
import 'package:GBPayUsers/features/home/widgets/box_section.dart';
import 'package:GBPayUsers/features/bills/view/bill_screen.dart';
import 'package:GBPayUsers/features/profile/view/profile_screen.dart';
import 'package:GBPayUsers/features/statistics/view/statistics_screen.dart';
import 'package:GBPayUsers/features/home/widgets/CustomBottomNavBar.dart';
import 'package:GBPayUsers/core/dynamic_form_service.dart';
import 'package:GBPayUsers/features/home/model/dynamic_form_model.dart';
import 'package:GBPayUsers/features/vehicles/views/vehicles_screen.dart'; // Import VehiclesScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  late TextEditingController _searchController;
  Color _dynamicColor = const Color(0xFF379E4B); // Default color
  List<DepartmentForm> forms = [];
  String departmentName = "Loading...";
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _searchController = TextEditingController();
    _fetchDynamicColor();
    _fetchForms();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
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

  Future<void> _fetchForms() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      DynamicFormResponse? response = await DynamicFormService.fetchDynamicForms();

      if (response != null && response.status && response.forms.isNotEmpty) {
        if (mounted) {
          setState(() {
            departmentName = response.forms.first.departmentName;
            forms = response.forms;
          });
        }
      } else {
        _showError("No Form Available\n Check your internet connection");
      }
    } catch (e) {
      _showError("No Form Available\n Check your internet connection");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        departmentName = message;
        forms = [];
        _hasError = true;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                shadowColor: Colors.transparent,
              ),
              child: RefreshIndicator(
                onRefresh: _fetchForms,
                color: _dynamicColor,
                backgroundColor: Colors.white,
                strokeWidth: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              HomeTopSection(
                                searchController: _searchController,
                                dynamicColor: _dynamicColor,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _isLoading
                                  ? SizedBox(
                                height: screenHeight * 0.5,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(_dynamicColor),
                                  ),
                                ),
                              )
                                  : _hasError
                                  ? SizedBox(
                                height: screenHeight * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      Text(
                                        departmentName,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      ElevatedButton(
                                        onPressed: _fetchForms,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _dynamicColor,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.05,
                                            vertical: screenHeight * 0.015,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text("Retry"),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : BoxSection(
                                title: departmentName,
                                forms: forms,
                                searchController: _searchController,
                                onSeeAllTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const BillScreen(),
            StatisticsScreen(dynamicColor: _dynamicColor),
            VehiclesScreen(dynamicColor: _dynamicColor), // Pass dynamicColor to VehiclesScreen
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        dynamicColor: _dynamicColor,
      ),
    );
  }
}