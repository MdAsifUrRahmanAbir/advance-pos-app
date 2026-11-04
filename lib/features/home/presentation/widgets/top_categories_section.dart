import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/dashboard_model.dart';
import '../states/dashboard_format.dart';
import 'dashboard_rank_badge.dart';
import 'dashboard_section_header.dart';
import 'dashboard_view_all_button.dart';

/// Top categories ranked by units sold. Shows the first [previewCount]
/// until "View all" is tapped; each bar is scaled to the best seller.
class TopCategoriesSection extends StatelessWidget {
  final List<Category> categories;
  final bool showAll;
  final VoidCallback onToggleShowAll;

  const TopCategoriesSection({
    super.key,
    required this.categories,
    required this.showAll,
    required this.onToggleShowAll,
  });

  static const int previewCount = 5;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visible = showAll || categories.length <= previewCount
        ? categories
        : categories.take(previewCount).toList();
    final maxQty = categories.fold<int>(
      0,
          (max, c) => c.totalQuantity > max ? c.totalQuantity : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: AppStrings.dashTopCategories,
          trailing: categories.length > previewCount
              ? DashboardViewAllButton(
            total: categories.length,
            expanded: showAll,
            onTap: onToggleShowAll,
          )
              : null,
        ),
        CustomCard(
          padding: const EdgeInsets.all(AppSizes.md),
          child: categories.isEmpty
              ? Text(
            AppStrings.dashNoData,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          )
              : Column(
            children: [
              for (var i = 0; i < visible.length; i++)
                _CategoryRow(
                  rank: i + 1,
                  data: visible[i],
                  fraction: maxQty > 0
                      ? visible[i].totalQuantity / maxQty
                      : 0,
                  isLast: i == visible.length - 1,
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

  /// Bar height and track tint — no token fits, flagged.
  static const double _barHeight = 6;
  static const double _trackAlpha = 0.12;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardRankBadge(rank: rank),
          const SizedBox(width: AppSizes.sm + AppSizes.xs),
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
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      DashboardFormat.money(data.totalAmount),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs + AppSizes.xs / 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  child: LinearProgressIndicator(
                    value: fraction.clamp(0.0, 1.0),
                    minHeight: _barHeight,
                    backgroundColor: AppColors.primary.withValues(alpha: _trackAlpha),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.dashQtySold(data.totalQuantity),
                  style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}