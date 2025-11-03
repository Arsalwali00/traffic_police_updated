import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/config/api.dart'; // Import ApiConfig

class HomeTopSection extends StatefulWidget {
  final TextEditingController searchController;
  final Color dynamicColor;

  static String? cachedUserName;
  static ImageProvider? cachedProfileImage;
  static ImageProvider? cachedDepartmentLogo;

  static void resetCachedData() {
    cachedUserName = null;
    cachedProfileImage = null;
    cachedDepartmentLogo = null;
  }

  const HomeTopSection({
    Key? key,
    required this.searchController,
    required this.dynamicColor,
  }) : super(key: key);

  @override
  _HomeTopSectionState createState() => _HomeTopSectionState();
}

class _HomeTopSectionState extends State<HomeTopSection> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (HomeTopSection.cachedUserName == null ||
        HomeTopSection.cachedProfileImage == null ||
        HomeTopSection.cachedDepartmentLogo == null) {
      _fetchUserData();
    }
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _fetchUserData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic>? userData = await LocalStorage.getUser();
      if (userData != null && mounted) {
        setState(() {
          HomeTopSection.cachedUserName = userData['name'] ?? "User";
          if (userData['profile_picture'] != null) {
            try {
              String base64String = userData['profile_picture'];
              if (base64String.startsWith('data:image')) {
                base64String = base64String.split(',')[1];
              }
              final bytes = base64Decode(base64String);
              HomeTopSection.cachedProfileImage = MemoryImage(bytes);
            } catch (e) {
              print("Error decoding profile picture: $e");
              HomeTopSection.cachedProfileImage = null;
            }
          }
          if (userData['department_logo'] != null) {
            try {
              String logoUrl = userData['department_logo'];
              // Use ApiConfig.assetBaseUrl for consistent URL construction
              if (!logoUrl.startsWith('http')) {
                logoUrl = "${ApiConfig.assetBaseUrl}/$logoUrl";
              }
              HomeTopSection.cachedDepartmentLogo = NetworkImage(logoUrl);
            } catch (e) {
              print("Error loading department logo: $e");
              HomeTopSection.cachedDepartmentLogo = null;
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        setState(() {
          HomeTopSection.cachedUserName = "Error";
          HomeTopSection.cachedProfileImage = null;
          HomeTopSection.cachedDepartmentLogo = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade300,
                    child: ClipOval(
                      child: HomeTopSection.cachedProfileImage != null
                          ? Image(
                        image: HomeTopSection.cachedProfileImage!,
                        fit: BoxFit.cover,
                        width: 44,
                        height: 44,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 40, color: Colors.black);
                        },
                      )
                          : const Icon(Icons.person, size: 40, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hi,", style: TextStyle(fontSize: 14, color: Colors.black54)),
                      Text(
                        HomeTopSection.cachedUserName ?? "User",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade300,
                child: ClipOval(
                  child: HomeTopSection.cachedDepartmentLogo != null
                      ? Image(
                    image: HomeTopSection.cachedDepartmentLogo!,
                    fit: BoxFit.cover,
                    width: 44,
                    height: 44,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.business, size: 40, color: Colors.black);
                    },
                  )
                      : const Icon(Icons.business, size: 40, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            focusNode: _searchFocusNode,
            controller: widget.searchController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Search forms",
              hintStyle: const TextStyle(color: Colors.black38),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: _buildBorder(widget.dynamicColor),
              enabledBorder: _buildBorder(widget.dynamicColor),
              focusedBorder: _buildBorder(widget.dynamicColor, width: 2.0),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.dynamicColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.searchController.text.isEmpty
                      ? IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      if (_searchFocusNode.hasFocus) {
                        _searchFocusNode.unfocus();
                      } else {
                        _searchFocusNode.requestFocus();
                      }
                    },
                  )
                      : IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      widget.searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                  ),
                ),
              ),
            ),
            onSubmitted: (value) {
              _searchFocusNode.unfocus();
            },
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}