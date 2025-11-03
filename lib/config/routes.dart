import 'package:flutter/material.dart';
import 'package:GBPayUsers/features/splash/view/splash_screen.dart';
import 'package:GBPayUsers/features/auth/view/login_screen.dart';
import 'package:GBPayUsers/features/auth/view/forgot_password_screen.dart';
import 'package:GBPayUsers/features/auth/view/otp_verification_screen.dart';
import 'package:GBPayUsers/features/auth/view/new_password_screen.dart';
import 'package:GBPayUsers/features/home/view/home_screen.dart';
import 'package:GBPayUsers/features/security/view/security_screen.dart';
import 'package:GBPayUsers/features/bills/view/bill_screen.dart';
import 'package:GBPayUsers/features/profile/view/profile_screen.dart';
import 'package:GBPayUsers/features/profile/view/edit_profile_screen.dart';
import 'package:GBPayUsers/features/settings/view/settings_screen.dart';
import 'package:GBPayUsers/features/profile/view/generated_vouchers_screen.dart'; // Added import

class Routes {
  /// ✅ **Define Route Names**
  static const String initial = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String newPasswordScreen = '/new-password';
  static const String home = '/home';
  static const String securitySettings = '/security-settings';
  static const String favorites = '/favorites';
  static const String bookings = '/bookings';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String generatedVouchers = '/generated-vouchers'; // Added new route

  /// ✅ **Define Named Routes**
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => SplashScreen(),
      login: (context) => LoginScreen(),
      forgotPassword: (context) => ForgetPasswordScreen(),
      otpVerification: (context) => OTPScreen(),
      newPasswordScreen: (context) => NewPasswordScreen(),
      home: (context) => HomeScreen(),
      securitySettings: (context) => SecurityScreen(),
      bookings: (context) => BillScreen(),
      profile: (context) => ProfileScreen(),
      editProfile: (context) => EditProfileScreen(),
      generatedVouchers: (context) => GeneratedVouchersScreen(), // Added to named routes
    };
  }

  /// ✅ **Dynamic Navigation Handling**
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    print("🔹 Navigating to: ${settings.name}");

    switch (settings.name) {
      case Routes.initial:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgetPasswordScreen());
      case Routes.otpVerification:
        return MaterialPageRoute(builder: (_) => OTPScreen());
      case Routes.newPasswordScreen:
        return MaterialPageRoute(builder: (_) => NewPasswordScreen());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case Routes.securitySettings:
        return MaterialPageRoute(builder: (_) => SecurityScreen());
      case Routes.favorites:
      case Routes.bookings:
        return MaterialPageRoute(builder: (_) => BillScreen());
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case Routes.editProfile:
        return MaterialPageRoute(builder: (_) => EditProfileScreen());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case Routes.generatedVouchers: // Added route handling
        return MaterialPageRoute(builder: (_) => GeneratedVouchersScreen());
      default:
        print("❌ ERROR: Undefined Route - ${settings.name}");
        return _errorRoute();
    }
  }

  /// ✅ **Handle Unknown Routes**
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    print("⚠️ Unknown Route Attempted: ${settings.name}");
    return _errorRoute();
  }

  /// 🚀 **Reusable 404 Error Page**
  static MaterialPageRoute _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            "🚫 404 - Page Not Found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
      ),
    );
  }
}