import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/secondary_button.dart';
import 'technical_details_panel.dart';

/// Warning icon mark, title/subtitle, a technical-details panel, and
/// Retry/Report Issue actions. Purely presentational — [errorDetails]
/// and both callbacks are supplied by the caller.
class ErrorContent extends StatelessWidget {
  final String errorDetails;
  final VoidCallback? onRetry;
  final VoidCallback? onReportIssue;

  const ErrorContent({
    super.key,
    required this.errorDetails,
    this.onRetry,
    this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppSvgIcon(
          assetPath: AppAssets.warningSVG,
          color: AppColors.error,
          size: AppSizes.xxl * 2 + AppSizes.xl,
        ),
        const SizedBox(height: AppSizes.xl),
         Text(
          AppStrings.errorTitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
        ),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
         Text(
          AppStrings.errorSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontMd, color: context.appColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: AppSizes.xl),
        TechnicalDetailsPanel(details: errorDetails),
        const SizedBox(height: AppSizes.lg),
        PrimaryButton(
          label: AppStrings.retry,
          onPressed: onRetry,
        ),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
        SecondaryButton(
          label: AppStrings.reportIssue,
          onPressed: onReportIssue,
        ),
      ],
    );
  }
}