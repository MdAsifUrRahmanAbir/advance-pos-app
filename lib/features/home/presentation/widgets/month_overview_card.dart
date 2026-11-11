import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';
import '../states/home_state.dart';

/// "Nov 2026 Overview · View invoices >" and a 2×2 grid: Sales, Returns,
/// Received (with expense), Net Balance.
class MonthOverviewCard extends StatelessWidget {
  final String title;
  final OverviewData sales;
  final SalesReturnClass salesReturn;
  final Balance balance;
  final VoidCallback? onViewAll;

  const MonthOverviewCard({
    super.key,
    required this.title,
    required this.sales,
    required this.salesReturn,
    required this.balance,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final net = balance.balance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.homeViewInvoices,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: AppSizes.iconSm,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        CustomCard(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MonthStat(
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primary,
                      label: AppStrings.dashSales,
                      value: DashboardFormat.money(sales.amount),
                      caption: AppStrings.homeSalesMeta(sales.orders, sales.items),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _MonthStat(
                      icon: Icons.assignment_return_outlined,
                      color: AppColors.warning,
                      label: AppStrings.salesReturnTitle,
                      value: DashboardFormat.money(salesReturn.amount),
                      caption: AppStrings.dashReturnMeta(
                        salesReturn.count,
                        salesReturn.quantity,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: _MonthStat(
                      icon: Icons.south_west_rounded,
                      color: AppColors.success,
                      label: AppStrings.dashReceived,
                      value: DashboardFormat.money(balance.totalReceive),
                      caption: AppStrings.dashExpenseLabel(
                        DashboardFormat.money(balance.totalExpense),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _MonthStat(
                      icon: Icons.account_balance_wallet_outlined,
                      color: net < 0 ? AppColors.error : AppColors.info,
                      label: AppStrings.dashNetBalance,
                      value: DashboardFormat.money(net),
                      caption: AppStrings.homeInMinusOut,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String caption;

  const _MonthStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.caption,
  });

  /// FLAG: no tint token.
  static const double _tintAlpha = 0.08;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + AppSizes.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _tintAlpha),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppSizes.iconSm),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textHint, fontSize: AppSizes.fontXs),
          ),
        ],
      ),
    );
  }
}