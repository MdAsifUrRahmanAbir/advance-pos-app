import 'package:flutter/material.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_color_scheme.dart';

/// Last row of an infinite-scroll list: a spinner while the next page
/// loads, or a short message with Retry when that load failed.
///
/// [message] defaults to [AppStrings.paginationLoadMoreFailed]; pass a
/// feature string to override it.
class PaginationFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;
  final String? message;

  const PaginationFooter({
    super.key,
    required this.isLoading,
    required this.onRetry,
    this.message,
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
              message ?? AppStrings.paginationLoadMoreFailed,
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