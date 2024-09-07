import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  // Constructor with obscureText parameter and default value
  CustomTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false, // Default is set to false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // Changes position of shadow
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText, // Use the obscureText parameter
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderSide: BorderSide.none, // Removes default border
            borderRadius: BorderRadius.zero, // Unrounded corners
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        ),
      ),
    );
  }
}
