import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';

/// Collection split by payment method (stacked bar + every method listed,
/// zero ones muted) followed by the extra charges (VAT, delivery, other).
class CollectionBreakdownCard extends StatelessWidget {
  final Collection collection;

  const CollectionBreakdownCard({super.key, required this.collection});

  static const double _barHeight = 10;

  @override
  Widget build(BuildContext context) {
    final slices = <_Slice>[
      _Slice(AppStrings.dashPayCash, collection.cashAmount, AppColors.success),
      _Slice(AppStrings.dashPayCard, collection.cardAmount, AppColors.primary),
      _Slice(
        AppStrings.dashPayBankCard,
        collection.bankCardAmount,
        AppColors.info,
      ),
      _Slice(
        AppStrings.dashPayMobile,
        collection.mobileAmount,
        AppColors.warning,
      ),
      _Slice(
        AppStrings.dashPayBank,
        collection.bankAmount,
        AppColors.textSecondary,
      ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    final total = slices.fold<double>(0, (sum, s) => sum + s.amount);

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  AppStrings.dashCollectionBreakdown,
                  style: TextStyle(
                    color: AppColors.textPrimary,
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
                  children: slices
                      .where((s) => s.amount > 0)
                      .map(
                        (s) => Expanded(
                      flex: (s.amount / total * 1000)
                          .round()
                          .clamp(1, 1000),
                      child: ColoredBox(color: s.color),
                    ),
                  )
                      .toList(),
                )
                    : const ColoredBox(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          ...slices.map((s) => _MethodRow(slice: s, total: total)),
          const Divider(height: AppSizes.lg, color: AppColors.border),
          const Text(
            AppStrings.dashCharges,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          _ChargeRow(AppStrings.dashVat, collection.vatAmount),
          _ChargeRow(
            AppStrings.dashDeliveryCharge,
            collection.deliveryChargeAmount,
          ),
          _ChargeRow(AppStrings.dashOtherCharge, collection.otherChargeAmount),
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

  static const double _dotSize = 8;
  static const double _percentWidth = 40;

  @override
  Widget build(BuildContext context) {
    final hasAmount = slice.amount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              color: hasAmount ? slice.color : slice.color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              slice.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ),
          Text(
            DashboardFormat.money(slice.amount),
            style: TextStyle(
              color: hasAmount ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: _percentWidth,
            child: Text(
              total > 0 ? '${(slice.amount / total * 100).round()}%' : '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontXs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChargeRow extends StatelessWidget {
  final String label;
  final double amount;

  const _ChargeRow(this.label, this.amount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          ),
          Text(
            DashboardFormat.money(amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}