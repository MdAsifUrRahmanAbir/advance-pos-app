import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Static helpers for showing consistent snackbars across the app.
class CustomSnackbar {
  CustomSnackbar._();

  static void show(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: AppColors.textWhite)),
        backgroundColor: error ? AppColors.error : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        margin: const EdgeInsets.all(AppSizes.md),
      ),
    );
  }
}
