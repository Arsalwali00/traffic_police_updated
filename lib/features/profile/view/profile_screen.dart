import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:GBPayUsers/config/routes.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:http/http.dart' as http;
import 'package:GBPayUsers/config/api.dart';
import 'package:GBPayUsers/features/home/widgets/home_top_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static String? _cachedUserName;
  static String? _cachedCellNumber;
  static String? _cachedCnicNumber;
  static String? _cachedEmail;
  static String? _cachedDepartmentName;
  static ImageProvider? _cachedProfileImage;
  Color _dynamicColor = const Color(0xFF379E4B); // Default color
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic>? userData = await LocalStorage.getUser();
      if (userData != null && mounted) {
        setState(() {
          _cachedUserName = userData['name'] ?? "Officer";
          _cachedCellNumber = userData['cell_number'] ?? "Not Provided";
          _cachedCnicNumber = userData['cnic_number'] ?? "Not Provided";
          _cachedEmail = userData['email'] ?? "Not Provided";
          _cachedDepartmentName = userData['department_name'] ?? "Not Provided";
          // Parse dynamic color
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
          if (userData['department_logo'] != null) {
            try {
              String logoUrl = userData['department_logo'];
              if (!logoUrl.startsWith('http')) {
                logoUrl = "${ApiConfig.assetBaseUrl}/$logoUrl";
              }
              _cachedProfileImage = NetworkImage(logoUrl);
            } catch (e) {
              print("Error loading department logo: $e");
              _cachedProfileImage = null;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cachedUserName = "Error";
          _cachedCellNumber = "Error";
          _cachedCnicNumber = "Error";
          _cachedEmail = "Error";
          _cachedDepartmentName = "Error";
          _cachedProfileImage = null;
          _dynamicColor = const Color(0xFF379E4B); // Fallback to default
        });
      }
      print("Error fetching user data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isLoggingOut ? null : _buildAppBar(context),
      body: _isLoggingOut
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_dynamicColor),
        ),
      )
          : (_isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_dynamicColor),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildProfileOptions(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      )),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Profile",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: _dynamicColor, size: 20),
          onPressed: () {
            Navigator.pushNamed(context, Routes.editProfile);
          },
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.logout, size: 26, color: Colors.red),
              ),
              const SizedBox(height: 12),
              const Text(
                'Confirm Logout',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 6),
              const Text(
                'Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        final token = await LocalStorage.getToken();
        if (token != null) {
          final response = await http.post(
            Uri.parse(API.logout),
            headers: {'Authorization': 'Bearer $token'},
          );
          if (response.statusCode == 200) {
            print('Logout API call successful');
          } else {
            print('Logout API call failed: ${response.statusCode}');
          }
        }
      } catch (e) {
        print('Error during logout API call: $e');
      }

      await LocalStorage.logout();

      setState(() {
        _cachedUserName = null;
        _cachedCellNumber = null;
        _cachedCnicNumber = null;
        _cachedEmail = null;
        _cachedDepartmentName = null;
        _cachedProfileImage = null;
        _dynamicColor = const Color(0xFF379E4B); // Reset to default
      });

      HomeTopSection.resetCachedData();

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
            (route) => false,
      );
    }
  }

  Widget _buildProfileHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: _cachedProfileImage,
              child: _cachedProfileImage == null
                  ? const Icon(Icons.person, size: 60, color: Colors.black54)
                  : null,
            ),
            Positioned(
              bottom: 3,
              right: 3,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white,
                child: Icon(Icons.verified, color: _dynamicColor, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _cachedUserName ?? "Officer",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProfileOption(
          Icons.phone,
          "Phone Number",
          _cachedCellNumber ?? "Not Provided",
        ),
        _buildProfileOption(
          Icons.credit_card,
          "CNIC Number",
          _cachedCnicNumber ?? "Not Provided",
        ),
        _buildProfileOption(
          Icons.email,
          "Email",
          _cachedEmail ?? "Not Provided",
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.generatedVouchers);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dynamicColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.receipt_long,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'Generated Vouchers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showLogoutDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: _dynamicColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}