import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../states/dashboard_format.dart';
import '../states/home_state.dart';

/// Gradient hero: total sales, order / item pills, and (today only, when
/// the API sends them) discount and VAT.
class SalesOverviewCard extends StatelessWidget {
  final OverviewData data;

  const SalesOverviewCard({super.key, required this.data});

  /// White overlays on the gradient — no AppColors tokens, flagged.
  static const double _softAlpha = 0.16;
  static const double _mutedAlpha = 0.75;
  static const double _dividerAlpha = 0.2;

  @override
  Widget build(BuildContext context) {
    final hasExtras = data.discount != null || data.vat != null;
    final muted = AppColors.textWhite.withValues(alpha: _mutedAlpha);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md + AppSizes.xs),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xs + AppSizes.xs / 2),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: _softAlpha),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                AppStrings.dashTotalSales,
                style: TextStyle(
                  color: muted,
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              DashboardFormat.money(data.amount),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: AppSizes.fontDisplay,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.xs,
            children: [
              _Pill(
                icon: Icons.receipt_long_outlined,
                text: AppStrings.dashOrdersCount(data.orders),
              ),
              _Pill(
                icon: Icons.inventory_2_outlined,
                text: AppStrings.dashItemsCount(data.items),
              ),
            ],
          ),
          if (hasExtras) ...[
            const SizedBox(height: AppSizes.md),
            Divider(
              height: 1,
              color: AppColors.textWhite.withValues(alpha: _dividerAlpha),
            ),
            const SizedBox(height: AppSizes.sm + AppSizes.xs),
            Row(
              children: [
                if (data.discount != null)
                  Expanded(
                    child: _HeroMetric(
                      label: AppStrings.invoiceDiscountLabel,
                      value: DashboardFormat.money(data.discount!),
                    ),
                  ),
                if (data.vat != null)
                  Expanded(
                    child: _HeroMetric(
                      label: AppStrings.invoiceVatLabel,
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

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + AppSizes.xs / 2,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: SalesOverviewCard._softAlpha),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.textWhite),
          const SizedBox(width: AppSizes.xs),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textWhite.withValues(alpha: SalesOverviewCard._mutedAlpha),
            fontSize: AppSizes.fontXs,
          ),
        ),
        const SizedBox(height: AppSizes.xs / 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}