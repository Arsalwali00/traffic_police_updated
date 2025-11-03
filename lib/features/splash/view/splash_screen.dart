import 'package:flutter/material.dart';
import '../presenter/splash_presenter.dart';
import 'package:GBPayUsers/config/routes.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashPresenter _presenter = SplashPresenter();

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  /// ✅ **Splash Timer Before Navigation**
  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      _navigate();
    });
  }

  /// ✅ **Handle Navigation Based on Login Status**
  void _navigate() {
    _presenter.checkAuthentication().then((isAuthenticated) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          isAuthenticated ? Routes.home : Routes.login,
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // ✅ Prevents back navigation
      child: Scaffold(
        backgroundColor: Colors.white, // ✅ White Background
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ✅ **Circular Dark Blue Loader with Larger Logo Inside**
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150, // Increased to accommodate larger logo
                    height: 150, // Increased to accommodate larger logo
                    child: CircularProgressIndicator(
                      strokeWidth: 4.5, // Thickness of the outer loader
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF00008B), // ✅ Dark Blue Loader
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/images/splash/logo.png",
                    width: 110, // Increased from 80 to 110
                    height: 110, // Increased from 80 to 110
                  ),
                ],
              ),
              const SizedBox(height: 10), // Adjust spacing

              /// ✅ **Gilgit Baltistan Police with Increased Font Size**
              const Text(
                "Gilgit Baltistan Police",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, // Increased from 10 to 16 for prominence
                  fontWeight: FontWeight.bold, // Bolder for emphasis
                  color: Color(0xFF00008B), // ✅ Dark Blue text for contrast
                ),
              ),
              const SizedBox(height: 8), // Small gap

              /// ✅ **Slogan Below Gilgit Baltistan Police**
              const Text(
                "Your Trusted Partner for Road Safety and Compliance",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13, // Original smaller text size
                  fontWeight: FontWeight.w400, // Regular weight
                  color: Color(0xFF00008B), // ✅ Dark Blue text for contrast
                ),
              ),
              const SizedBox(height: 13), // Small gap

              /// ✅ **Traffic Violation Fines**
              const Text(
                "Traffic Violation Fines",
                style: TextStyle(
                  fontSize: 14, // Slightly larger
                  // fontWeight: FontWeight.bold, // Bolder weight
                  color: Color(0xFF00008B), // ✅ Dark Blue text for contrast
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}