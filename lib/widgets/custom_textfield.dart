import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextStyle? hintStyle;
  final IconData? prefixIcon;
  final bool obscureText;
  final List<String>? autofillHints;
  final bool enabled;
  final bool readOnly; // <--- ADDED THIS
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final TextInputType? textInputType; // Helper for older code using this name
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false, // <--- ADDED THIS (Default false)
    this.suffixIcon,
    this.keyboardType,
    this.textInputType, // Helper
    this.maxLines = 1, // Default to 1 line for standard input
    this.onChanged,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.black1;
    final hintColor = theme.hintColor;
    final decorationTheme = theme.inputDecorationTheme;

    return TextField(
      onChanged: onChanged,
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly, // <--- CONNECTED HERE
      maxLines: maxLines,
      autofillHints: autofillHints,
      // Support both naming conventions if you had 'textInputType' elsewhere
      keyboardType: textInputType ?? keyboardType,
      cursorColor: AppColors.primary5,
      style: TextStyle(
        color: textColor,
        fontFamily: 'Poppins',
        fontSize: Dimensions.font15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle:
            hintStyle ??
            TextStyle(
              color: hintColor,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
        hintText: hintText,
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary4)
                : null,
        suffixIcon: suffixIcon,
        hintStyle:
            hintStyle ??
            TextStyle(
              color: hintColor,
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
              fontWeight: FontWeight.w400,
            ),
        contentPadding: decorationTheme.contentPadding,
        filled: decorationTheme.filled,
        fillColor: decorationTheme.fillColor,
        border: decorationTheme.border,
        enabledBorder: decorationTheme.enabledBorder,
        focusedBorder: decorationTheme.focusedBorder,
        errorBorder: decorationTheme.errorBorder,
        focusedErrorBorder: decorationTheme.focusedErrorBorder,
      ),
    );
  }
}
