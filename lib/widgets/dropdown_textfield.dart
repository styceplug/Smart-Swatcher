import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';

class DropdownTextField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selectedItem;
  final void Function(T?) onChanged;
  final String Function(T) itemToString;
  final String? hintText;
  final Color? backgroundColor;

  const DropdownTextField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.itemToString,
    this.hintText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveFillColor =
        backgroundColor ??
        theme.inputDecorationTheme.fillColor ??
        AppColors.primary1;
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.black1;
    final normalizedSelectedItem =
        items.contains(selectedItem) ? selectedItem : null;
    final decorationTheme = theme.inputDecorationTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font14,
                color: textColor,
              ),
            ),
          ),
        DropdownButtonFormField<T>(
          initialValue: normalizedSelectedItem,
          dropdownColor: Colors.white,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Poppins',
            fontSize: Dimensions.font15,
            fontWeight: FontWeight.w500,
          ),
          iconEnabledColor: AppColors.primary4,
          decoration: InputDecoration(
            filled: true,
            fillColor: effectiveFillColor,
            hintText: hintText ?? "Select an option",
            hintStyle: TextStyle(
              color: theme.hintColor,
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
              fontWeight: FontWeight.w400,
            ),
            border: decorationTheme.border,
            enabledBorder: decorationTheme.enabledBorder,
            focusedBorder: decorationTheme.focusedBorder,
            errorBorder: decorationTheme.errorBorder,
            focusedErrorBorder: decorationTheme.focusedErrorBorder,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.width15,
              vertical: Dimensions.height12,
            ),
          ),
          items:
              items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemToString(item),
                    style: TextStyle(color: textColor),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
