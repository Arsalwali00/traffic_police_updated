import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:GBPayUsers/config/routes.dart';
import 'package:GBPayUsers/features/shared/widgets/custom_textfield.dart';
import 'package:GBPayUsers/features/shared/widgets/custom_button.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  bool _isPhoneSelected = true; // Toggle between Phone & Email
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _saveLoginInfo = false; // Checkbox state

  void _sendCode() {
    if (_isPhoneSelected) {
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your phone number")),
        );
        return;
      }
    } else {
      if (_emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your email/username")),
        );
        return;
      }
    }

    // TODO: Implement OTP/Password Reset Logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Verification code sent!")),
    );

    // ✅ Navigate to OTP Verification Screen
    Navigator.pushNamed(context, Routes.otpVerification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // ✅ Prevents overflow on small screens
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Forget Password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ✅ Tab Selection (Phone / Email)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isPhoneSelected = true),
                  child: Column(
                    children: [
                      Text(
                        "Phone",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isPhoneSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (_isPhoneSelected)
                        Container(height: 2, width: 40, color: Colors.black),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () => setState(() => _isPhoneSelected = false),
                  child: Column(
                    children: [
                      Text(
                        "Email/Username",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: !_isPhoneSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (!_isPhoneSelected)
                        Container(height: 2, width: 80, color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Phone Number or Email Field
            _isPhoneSelected
                ? IntlPhoneField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              initialCountryCode: 'PK', // Default Pakistan +92
              onChanged: (phone) {},
            )
                : CustomTextField(
              controller: _emailController,
              hintText: "Email / Username",
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 10),

            // ✅ Save Login Info Checkbox (Fixed Overflow)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align checkbox & text
              children: [
                Checkbox(
                  value: _saveLoginInfo,
                  onChanged: (value) {
                    setState(() {
                      _saveLoginInfo = value!;
                    });
                  },
                  activeColor: Colors.pink,
                ),
                const Expanded( // ✅ Prevents overflow
                  child: Text(
                    "Save login info to log in automatically next time",
                    maxLines: 2, // ✅ Ensures text wraps if needed
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Send Code Button using CustomButton
            CustomButton(text: "Send Code", onPressed: _sendCode),
          ],
        ),
      ),
    );
  }
}
