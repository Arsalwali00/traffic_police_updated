import 'package:flutter/material.dart';
import 'package:GBPayUsers/config/routes.dart';
import 'package:GBPayUsers/features/shared/widgets/custom_button.dart';
import 'package:GBPayUsers/features/shared/widgets/custom_textfield.dart';

class NewPasswordScreen extends StatefulWidget {
  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _resetPassword() {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    // TODO: Implement password reset logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password reset successfully!")),
    );

    // Navigate to Login screen
    Navigator.pushNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Create New Password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Set a new password for your account",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Password Fields
            CustomTextField(
              controller: _passwordController,
              hintText: "New Password",
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: "Confirm Password",
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Reset Password Button
            CustomButton(
              text: "Reset Password",
              onPressed: _resetPassword,
              color: Colors.pink,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
