import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';
import 'dashboard_rank_badge.dart';
import 'dashboard_section_header.dart';

/// All top categories ranked by revenue; each bar is scaled to the best one.
class TopCategoriesSection extends StatelessWidget {
  final List<Category> categories;

  const TopCategoriesSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final maxAmount = categories.fold<double>(
      0,
          (max, c) => c.totalAmount > max ? c.totalAmount : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(title: AppStrings.dashTopCategories),
        CustomCard(
          padding: const EdgeInsets.all(AppSizes.md),
          child: categories.isEmpty
              ? const Text(
            AppStrings.dashNoData,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          )
              : Column(
            children: [
              for (var i = 0; i < categories.length; i++)
                _CategoryRow(
                  rank: i + 1,
                  data: categories[i],
                  fraction: maxAmount > 0
                      ? categories[i].totalAmount / maxAmount
                      : 0,
                  isLast: i == categories.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final int rank;
  final Category data;
  final double fraction; // 0.0–1.0
  final bool isLast;

  const _CategoryRow({
    required this.rank,
    required this.data,
    required this.fraction,
    required this.isLast,
  });

  static const double _barHeight = 6;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardRankBadge(rank: rank),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.catName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      DashboardFormat.money(data.totalAmount),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  child: LinearProgressIndicator(
                    value: fraction.clamp(0.0, 1.0),
                    minHeight: _barHeight,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.dashQtySold(data.totalQuantity),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}