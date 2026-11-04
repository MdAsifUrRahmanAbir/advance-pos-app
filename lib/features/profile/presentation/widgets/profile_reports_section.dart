import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/square_icon_tile.dart';

/// Reports on the Profile ("More") screen as a row of colourful quick-
/// action tiles: Customers, Expense, Sales Replacement. Stock report and
/// Sales Return callbacks stay for when those tiles come back.
class ProfileReportsSection extends StatelessWidget {
  final VoidCallback? onStockReportTap;
  final VoidCallback? onSalesReturnTap;
  final VoidCallback? onSalesReplacementTap;
  final VoidCallback? onExpenseTap;
  final VoidCallback? onCustomerTap;

  const ProfileReportsSection({
    super.key,
    this.onCustomerTap,
    this.onStockReportTap,
    this.onSalesReturnTap,
    this.onSalesReplacementTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(AppStrings.reportsSection),
        const SizedBox(height: AppSizes.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ReportTile(
                  icon: Icons.people_alt_outlined,
                  title: AppStrings.customersTitle,
                  color: AppColors.primary,
                  onTap: onCustomerTap,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _ReportTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: AppStrings.expense,
                  color: AppColors.warning,
                  onTap: onExpenseTap,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _ReportTile(
                  icon: Icons.swap_horiz_rounded,
                  title: AppStrings.repTitle,
                  color: AppColors.accent,
                  onTap: onSalesReplacementTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Same style as [SettingsGroup]'s label.
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  /// Matches SettingsGroup — no AppSizes token, flagged.
  static const double _letterSpacing = 0.5;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppSizes.fontXs,
        fontWeight: FontWeight.w700,
        color: context.appColors.textSecondary,
        letterSpacing: _letterSpacing,
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _ReportTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.md,
      ),
      child: Column(
        children: [
          SquareIconTile(
            icon: icon,
            color: color,
            padding: AppSizes.sm + AppSizes.xs,
            radius: AppSizes.radiusMd,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
