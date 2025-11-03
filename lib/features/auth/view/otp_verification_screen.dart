import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:GBPayUsers/config/routes.dart';
import 'package:GBPayUsers/features/shared/widgets/custom_button.dart';

class OTPScreen extends StatefulWidget {
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otpCode = "";

  void _verifyOTP() {
    if (otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 4-digit OTP")),
      );
      return;
    }

    // TODO: Implement OTP verification logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP Verified!")),
    );

    // Navigate to the next screen
    Navigator.pushNamed(context, Routes.newPasswordScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // ✅ Title
              const Text(
                "Enter your code",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Enter your code to begin journey",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // ✅ OTP Instruction
              const Text(
                "OTP has been sent to you on your mobile number, please enter it below",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // ✅ OTP Input Field
              OtpTextField(
                numberOfFields: 4,
                borderColor: Colors.black,
                fieldWidth: 55,
                focusedBorderColor: Colors.pink, // Highlight color on focus
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                showFieldAsBox: true,
                borderRadius: BorderRadius.circular(10),
                onCodeChanged: (String code) {},
                onSubmit: (String verificationCode) {
                  setState(() {
                    otpCode = verificationCode;
                  });
                  _verifyOTP();
                },
              ),

              const SizedBox(height: 20),

              // ✅ Don't receive OTP?
              const Text(
                "Don't receive OTP?",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Divider(thickness: 1, color: Colors.grey),

              const SizedBox(height: 20),

              // ✅ Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Resend OTP Button
                  Expanded(
                    child: CustomButton(
                      text: "Resend OTP",
                      onPressed: () {
                        // TODO: Implement OTP Resend logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("OTP Resent!")),
                        );
                      },
                      color: Colors.white,
                      textColor: Colors.black,

                    ),
                  ),
                  const SizedBox(width: 10),

                  // Edit Number Button
                  Expanded(
                    child: CustomButton(
                      text: "Edit Number",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.pink,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
