import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';
import 'dashboard_metric.dart';

/// Net balance (red when negative) with received vs expense underneath.
class CashFlowCard extends StatelessWidget {
  final Balance balance;

  const CashFlowCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final isNegative = balance.balance < 0;
    final accent = isNegative ? AppColors.error : AppColors.success;

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: AppSizes.iconSm,
                  color: accent,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Text(
                AppStrings.dashNetBalance,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              DashboardFormat.money(balance.balance),
              style: TextStyle(
                color: accent,
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: DashboardMetric(
                  label: AppStrings.dashReceived,
                  value: DashboardFormat.money(balance.totalReceive),
                  valueColor: AppColors.success,
                ),
              ),
              Expanded(
                child: DashboardMetric(
                  label: AppStrings.dashExpense,
                  value: DashboardFormat.money(balance.totalExpense),
                  valueColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}