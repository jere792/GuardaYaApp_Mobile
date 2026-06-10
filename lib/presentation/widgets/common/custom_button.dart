import 'package:flutter/material.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? Colors.white;

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
            : icon != null ? Icon(icon, color: AppColors.primary) : const SizedBox.shrink(),
        label: Text(text, style: TextStyle(color: txtColor)),
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: txtColor))
          : icon != null ? Icon(icon, color: txtColor) : const SizedBox.shrink(),
      label: Text(text),
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: txtColor),
    );
  }
}