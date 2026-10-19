import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// Bottom of the list: a spinner while the next page loads, or a message
/// with Retry when that load failed.
class SalesReplacementListFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;

  const SalesReplacementListFooter({
    super.key,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.srLoadMoreFailed,
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}