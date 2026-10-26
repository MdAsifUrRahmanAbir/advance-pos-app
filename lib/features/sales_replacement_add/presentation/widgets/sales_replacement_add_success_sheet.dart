import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/primary_button.dart';

/// Shown after `POST /s_return/add` succeeds. It can't be swiped or
/// back-buttoned away — Done is the only exit, so the flow always unwinds
/// back to the replacement list.
class SalesReplacementAddSuccessSheet extends StatelessWidget {
  final String billNo;
  final VoidCallback onDone;

  const SalesReplacementAddSuccessSheet({
    super.key,
    required this.billNo,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.lg,
          AppSizes.md,
          AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: AppSizes.xxl,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                AppStrings.repaCreatedTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppSizes.fontXxl,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (billNo.isNotEmpty) ...[
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.repaCreatedSubtitle(billNo),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              PrimaryButton(label: AppStrings.done, onPressed: onDone),
            ],
          ),
        ),
      ),
    );
  }
}