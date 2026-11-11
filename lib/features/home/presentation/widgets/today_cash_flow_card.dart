import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';

/// "Today's Cash Flow": icon + title, a profit/loss pill, then three
/// tiles — Received, Expense, Net Balance.
class TodayCashFlowCard extends StatelessWidget {
  final Balance balance;

  const TodayCashFlowCard({super.key, required this.balance});

  /// FLAG: no icon-tile / tint tokens.
  static const double _iconTileSize = 40;
  static const double _tintAlpha = 0.12;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final net = balance.balance;
    final isProfit = net >= 0;

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: _iconTileSize,
                height: _iconTileSize,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: _tintAlpha),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.sm + AppSizes.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.homeCashFlowTitle,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppStrings.homeCashFlowSubtitle,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: AppSizes.fontXs,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: isProfit ? AppStrings.homeInProfit : AppStrings.homeInLoss,
                color: isProfit ? AppColors.success : AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _FlowStat(
                      icon: Icons.south_west_rounded,
                      color: AppColors.success,
                      label: AppStrings.dashReceived,
                      value: DashboardFormat.money(balance.totalReceive),
                      caption: AppStrings.homeMoneyIn,
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.border),
                  Expanded(
                    child: _FlowStat(
                      icon: Icons.north_east_rounded,
                      color: AppColors.error,
                      label: AppStrings.expense,
                      value: DashboardFormat.money(balance.totalExpense),
                      caption: AppStrings.homeMoneyOut,
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.border),
                  Expanded(
                    child: _FlowStat(
                      icon: Icons.account_balance_outlined,
                      color: colors.textSecondary,
                      label: AppStrings.dashNetBalance,
                      value: DashboardFormat.money(net),
                      valueColor: isProfit ? null : AppColors.error,
                      caption: AppStrings.homeInMinusOut,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: TodayCashFlowCard._tintAlpha),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.xs + AppSizes.xs / 2,
            height: AppSizes.xs + AppSizes.xs / 2,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String caption;
  final Color? valueColor;

  const _FlowStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.caption,
    this.valueColor,
  });

  /// FLAG: no icon-circle size token.
  static const double _circleSize = 36;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Column(
        children: [
          Container(
            width: _circleSize,
            height: _circleSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: TodayCashFlowCard._tintAlpha),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppSizes.iconSm),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
          ),
          const SizedBox(height: AppSizes.xs / 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? colors.textPrimary,
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xs / 2),
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