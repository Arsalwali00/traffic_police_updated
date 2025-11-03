import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GBPayUsers/core/local_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  ImageProvider? _currentProfileImage;
  Color _dynamicColor = const Color(0xFF379E4B); // Default color
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic>? userData = await LocalStorage.getUser();
      if (userData != null && mounted) {
        setState(() {
          _phoneController.text = userData['cell_number'] ?? '';
          _emailController.text = userData['email'] ?? '';
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
          if (userData['profile_picture'] != null) {
            try {
              String base64String = userData['profile_picture'];
              if (base64String.startsWith('data:image')) {
                base64String = base64String.split(',')[1];
              }
              final bytes = base64Decode(base64String);
              _currentProfileImage = MemoryImage(bytes);
            } catch (e) {
              print("Error decoding profile picture: $e");
              _currentProfileImage = null;
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUserData() async {
    try {
      Map<String, dynamic> updatedFields = {
        'cell_number': _phoneController.text,
        'email': _emailController.text,
        'color': '0x${_dynamicColor.value.toRadixString(16).padLeft(8, '0').substring(2)}', // Preserve color
      };

      if (_passwordController.text.isNotEmpty) {
        updatedFields['password'] = _passwordController.text;
      }

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        updatedFields['profile_picture'] = 'data:image/jpeg;base64,$base64Image';
      }

      await LocalStorage.updateUser(updatedFields);
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_dynamicColor),
          ),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildProfileImage(),
                const SizedBox(height: 25),
                _buildTextField(Icons.phone, "Phone Number", _phoneController, false),
                _buildTextField(Icons.email, "Email", _emailController, false),
                _buildTextField(Icons.lock, "New Password", _passwordController, true),
                const SizedBox(height: 30),
                _buildUpdateButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        "Edit Profile",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: _selectedImage != null
              ? FileImage(_selectedImage!)
              : _currentProfileImage,
          child: _selectedImage == null && _currentProfileImage == null
              ? const Icon(Icons.person, color: Colors.black54, size: 50)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: _dynamicColor,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(IconData icon, String hintText, TextEditingController controller, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _dynamicColor),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: _dynamicColor,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          )
              : null,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black45),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: _dynamicColor),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          await _updateUserData();
          Navigator.pop(context, {
            'phoneNumber': _phoneController.text,
            'email': _emailController.text,
            'profileImage': _selectedImage,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _dynamicColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          "Update",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}