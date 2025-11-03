import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final IconData? icon; // ✅ Optional icon support

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF379E4B), // ✅ Green button color
    this.textColor = Colors.white, // ✅ White text for contrast
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52, // ✅ Slightly taller for a premium feel
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // ✅ Uses assigned button color (default: Green)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // ✅ Softer rounded edges
          ),
          elevation: 5, // ✅ Adds a subtle shadow effect
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: textColor, size: 22), // ✅ Show icon if provided
            if (icon != null) const SizedBox(width: 10), // ✅ Smooth spacing if icon exists
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold, // ✅ Bolder text for better readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}
