import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 52,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = isOutlined
        ? Colors.transparent
        : (backgroundColor ?? AppColors.primary);
    final effectiveTextColor = isOutlined
        ? (textColor ?? AppColors.primary)
        : (textColor ?? AppColors.textWhite);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: backgroundColor ?? AppColors.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                backgroundColor: effectiveBg,
              ),
              child: _buildChild(effectiveTextColor),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveBg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: _buildChild(effectiveTextColor),
            ),
    );
  }

  Widget _buildChild(Color currentTextColor) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(currentTextColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: currentTextColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.labelLarge.copyWith(color: currentTextColor),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTypography.labelLarge.copyWith(color: currentTextColor),
    );
  }
}
