import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText ? _isObscured : false,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        style: const TextStyle(color: Colors.black, fontSize: 16), // ✅ Black input text
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: Colors.black), // ✅ Black icon
          suffixIcon: widget.obscureText
              ? GestureDetector(
            onTap: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
                key: ValueKey<bool>(_isObscured),
                color: Colors.black, // ✅ Black visibility icon
              ),
            ),
          )
              : null,
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Colors.black, // ✅ Black hint text
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.1), // ✅ Semi-transparent black fill
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF00008B).withOpacity(0.6), // ✅ Dark blue border
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF00008B), // ✅ Bold dark blue on focus
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ), // ✅ Red border on error
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2.5,
            ), // ✅ Bolder red on focused error
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 20), // ✅ Comfortable spacing
        ),
      ),
    );
  }
}