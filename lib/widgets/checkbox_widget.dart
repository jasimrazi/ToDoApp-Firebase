// Custom circular green checkbox
import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Circular checkbox
          color:
              value ? Colors.green : Colors.transparent, // Green when checked
          border: Border.all(
            color: Colors.green,
            width: 2.0,
          ),
        ),
        child: value
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }
}
