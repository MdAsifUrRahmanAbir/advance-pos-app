import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_colors.dart';
import 'package:template_test/core/constants/app_sizes.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double? iconSize;
  final bool filled;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.iconSize,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: iconSize ?? AppSizes.iconMd,
      color: color ?? AppColors.textPrimary,
      style: IconButton.styleFrom(
        backgroundColor: filled ? (backgroundColor ?? AppColors.primaryLight) : null,
        foregroundColor: color ?? AppColors.textPrimary,
        disabledForegroundColor: AppColors.textHint,
        padding: const EdgeInsets.all(AppSizes.sm),
      ),
      icon: Icon(icon),
    );
    return button;
  }
}
