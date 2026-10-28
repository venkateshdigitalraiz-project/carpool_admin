import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.hintStyle,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTypography.titleMedium.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle ??
                AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primaryNavy, size: 22)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
