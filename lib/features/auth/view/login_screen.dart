import 'package:flutter/material.dart';
import 'package:GBPayUsers/features/auth/presenter/auth_presenter.dart';
import 'package:GBPayUsers/features/auth/model/login_model.dart';
import 'package:GBPayUsers/config/routes.dart';
import 'package:GBPayUsers/features/shared/widgets/custom_textfield.dart';
import 'package:GBPayUsers/features/shared/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _cnicOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthPresenter _presenter = AuthPresenter();

  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _cnicOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message, bool isNetworkError) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center, // ✅ Center the icon
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error,
              color: isNetworkError ? Colors.orange : Colors.red,
              size: 48, // ✅ Increased icon size
            ),
            const SizedBox(height: 8),
            const Text(
              'Error',
              style: TextStyle(
                color: Color(0xFF00008B),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          textAlign: TextAlign.center, // ✅ Center the error message
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF00008B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  void _login() async {
    String cnicOrEmail = _cnicOrEmailController.text.trim();
    String password = _passwordController.text;

    if (cnicOrEmail.isEmpty || password.isEmpty) {
      _showErrorDialog("Email/CNIC and Password are required!", false);
      return;
    }

    setState(() => _isLoading = true);

    LoginModel user = LoginModel(email: cnicOrEmail, password: password);

    Map<String, dynamic> response = await _presenter.login(user, rememberMe: _rememberMe);
    bool isSuccess = response['success'] == true;

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (isSuccess) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
      }
    } else {
      if (mounted) {
        _showErrorDialog(
          response['message'] ?? "An error occurred.",
          response['isNetworkError'] ?? false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/auth/logo.png",
                      height: 150,
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      "Gilgit Baltistan Police",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00008B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Your Trusted Partner for Road Safety and Compliance", // ✅ Fixed typo
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF00008B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              CustomTextField(
                controller: _cnicOrEmailController,
                hintText: "Email/CNIC",
                icon: Icons.perm_identity,
              ),
              CustomTextField(
                controller: _passwordController,
                hintText: "Password",
                icon: Icons.lock,
                obscureText: true,
              ),

              const SizedBox(height: 5),

              const SizedBox(height: 40),

              _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00008B),
                ),
              )
                  : CustomButton(
                text: "Login",
                onPressed: _login,
                color: const Color(0xFF00008B),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}