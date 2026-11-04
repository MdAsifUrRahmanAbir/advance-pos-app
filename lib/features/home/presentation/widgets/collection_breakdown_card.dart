import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';

/// Collection split by payment method: a stacked proportion bar, then only
/// the methods that collected something, then the extra charges (VAT,
/// delivery, other) as three mini stats.
class CollectionBreakdownCard extends StatelessWidget {
  final Collection collection;

  const CollectionBreakdownCard({super.key, required this.collection});

  /// Bar height and tint — no token fits, flagged.
  static const double _barHeight = 10;
  static const double _tintAlpha = 0.06;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final slices = <_Slice>[
      _Slice(AppStrings.dashPayCash, collection.cashAmount, AppColors.success),
      _Slice(AppStrings.dashPayCard, collection.cardAmount, AppColors.primary),
      _Slice(AppStrings.dashPayBankCard, collection.bankCardAmount, AppColors.info),
      _Slice(AppStrings.dashPayMobile, collection.mobileAmount, AppColors.warning),
      _Slice(AppStrings.dashPayBank, collection.bankAmount, AppColors.textSecondary),
    ].where((s) => s.amount > 0).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final total = slices.fold<double>(0, (sum, s) => sum + s.amount);

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.dashCollectionBreakdown,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                DashboardFormat.money(collection.amount),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Skeleton.leaf(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: SizedBox(
                height: _barHeight,
                child: total > 0
                    ? Row(
                        children: [
                          for (final s in slices)
                            Expanded(
                              flex: (s.amount / total * 1000).round().clamp(1, 1000),
                              child: ColoredBox(color: s.color),
                            ),
                        ],
                      )
                    : ColoredBox(color: colors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          if (slices.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Text(
                AppStrings.dashNoData,
                style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontSm),
              ),
            )
          else
            ...slices.map((s) => _MethodRow(slice: s, total: total)),
          const SizedBox(height: AppSizes.xs),
          Text(
            AppStrings.dashCharges,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.sm + AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: _tintAlpha),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                _ChargeStat(AppStrings.invoiceVatLabel, collection.vatAmount),
                _ChargeStat(AppStrings.dashDeliveryCharge, collection.deliveryChargeAmount),
                _ChargeStat(AppStrings.dashOtherCharge, collection.otherChargeAmount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Slice {
  final String label;
  final double amount;
  final Color color;

  const _Slice(this.label, this.amount, this.color);
}

class _MethodRow extends StatelessWidget {
  final _Slice slice;
  final double total;

  const _MethodRow({required this.slice, required this.total});

  /// Dot and percent column sizes — no token fits, flagged.
  static const double _dotSize = 10;
  static const double _percentWidth = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm + AppSizes.xs / 2),
      child: Row(
        children: [
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              color: slice.color,
              borderRadius: BorderRadius.circular(AppSizes.xs / 2),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              slice.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontSm),
            ),
          ),
          Text(
            DashboardFormat.money(slice.amount),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: _percentWidth,
            child: Text(
              '${(slice.amount / total * 100).round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(color: colors.textHint, fontSize: AppSizes.fontXs),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChargeStat extends StatelessWidget {
  final String label;
  final double amount;

  const _ChargeStat(this.label, this.amount);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Column(
        children: [
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
              DashboardFormat.money(amount),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
