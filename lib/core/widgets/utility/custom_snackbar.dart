import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Static helpers for showing consistent snackbars across the app.
class CustomSnackbar {
  CustomSnackbar._();

  /// [actionLabel] + [onAction] add an optional button (e.g. Retry).
  static void show(
      BuildContext context,
      String message, {
        bool error = false,
        String? actionLabel,
        VoidCallback? onAction,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: AppColors.textWhite)),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
          label: actionLabel,
          textColor: AppColors.textWhite,
          onPressed: onAction,
        )
            : null,
        backgroundColor: error ? AppColors.error : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        margin: const EdgeInsets.all(AppSizes.md),
      ),
    );
  }
}