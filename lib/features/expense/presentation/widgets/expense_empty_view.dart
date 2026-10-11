import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// "Nothing matches" state for the expense list.
/// TODO: swap for core EmptyState if its API fits.
class ExpenseEmptyView extends StatelessWidget {
  const ExpenseEmptyView({super.key});

  static const double _iconSize = 48;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: _iconSize,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSizes.md),
          Text(
            AppStrings.expEmptyTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            AppStrings.expEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          ),
        ],
      ),
    );
  }
}