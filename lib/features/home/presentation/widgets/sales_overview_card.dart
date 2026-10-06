import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../states/dashboard_format.dart';
import '../states/home_state.dart';
import 'dashboard_metric.dart';

/// Hero card: total sales with order/item pills. Discount and VAT are only
/// provided by the API for today, so that row appears only when present.
class SalesOverviewCard extends StatelessWidget {
  final OverviewData data;

  const SalesOverviewCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hasExtras = data.discount != null || data.vat != null;

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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Text(
                AppStrings.dashTotalSales,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              DashboardFormat.money(data.amount),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.xs,
            children: [
              _InfoPill(
                icon: Icons.shopping_bag_outlined,
                text: AppStrings.dashOrdersCount(data.orders),
              ),
              _InfoPill(
                icon: Icons.inventory_2_outlined,
                text: AppStrings.dashItemsCount(data.items),
              ),
            ],
          ),
          if (hasExtras) ...[
            const SizedBox(height: AppSizes.md),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                if (data.discount != null)
                  Expanded(
                    child: DashboardMetric(
                      label: AppStrings.dashDiscount,
                      value: DashboardFormat.money(data.discount!),
                    ),
                  ),
                if (data.vat != null)
                  Expanded(
                    child: DashboardMetric(
                      label: AppStrings.dashVat,
                      value: DashboardFormat.money(data.vat!),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.primary),
          const SizedBox(width: AppSizes.xs),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}