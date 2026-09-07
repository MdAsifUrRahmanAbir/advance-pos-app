import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_sizes.dart';

import '../../theme/app_color_scheme.dart';

class CustomDialog {
  CustomDialog._();

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.surface,
        title: Text(title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.xxl * 8),
          child: child,
        ),
        actions: actions,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      ),
    );
  }
}
