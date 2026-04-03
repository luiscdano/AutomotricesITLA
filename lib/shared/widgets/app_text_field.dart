import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.textColor,
    this.fillColor,
    this.labelColor,
    this.hintColor,
    this.borderColor,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Color? textColor;
  final Color? fillColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: borderColor ?? Colors.grey.shade400),
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      style: textColor != null ? TextStyle(color: textColor) : null,
      cursorColor: textColor,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: labelColor != null ? TextStyle(color: labelColor) : null,
        hintStyle: hintColor != null ? TextStyle(color: hintColor) : null,
        filled: fillColor != null,
        fillColor: fillColor,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: borderColor ?? Theme.of(context).colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
